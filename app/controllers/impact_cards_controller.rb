# frozen_string_literal: true

require 'English'
require 'csv'

# Controller for the ImpactCard model
# rubocop:disable Metrics/ClassLength
class ImpactCardsController < ApplicationController
  include VerifyPolicies
  include InitiativeChildRecords
  include ActiveTabItem

  before_action :set_scorecard, except: %i[index new create]
  before_action :require_workspace_selected, only: %i[new create edit update show_shared_link]

  sidebar_item :impact_cards
  tab_item :grid

  def index # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @communities = current_workspace.communities
    @wicked_problems = current_workspace.wicked_problems

    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(Scorecard).order(:name).ransack(search_params[:q])

    impact_cards = @q.result(distinct: true)

    @pagy, @impact_cards = pagy(impact_cards, limit: 10)

    @all_data_models = impact_cards.map(&:data_model).uniq

    respond_to do |format|
      format.html { render 'impact_cards/index', locals: { impact_cards: @impact_cards } }
      format.turbo_stream { render 'impact_cards/index', locals: { impact_cards: @impact_cards } }
    end
  end

  def show # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @legend_items = fetch_legend_items(@scorecard)

    @date = params[:date]
    @parsed_date = @date.blank? ? nil : Date.parse(@date)

    @subsystem_tags = @scorecard.subsystem_tags.order('lower(trim(subsystem_tags.name))').uniq
    @statuses = ChecklistItem.statuses.keys.excluding('no_comment').map { |status| [status.humanize, status] }

    @selected_statuses = Array.wrap(params[:statuses])

    @focus_areas = FocusArea.per_data_model(@scorecard.data_model_id).order(
      'focus_area_groups.position', :position
    )

    @selected_subsystem_tags =
      if params[:subsystem_tags].blank?
        SubsystemTag.none
      else
        SubsystemTag.where(workspace: @scorecard.workspace, name: params[:subsystem_tags].compact)
      end

    @scorecard_grid = ScorecardGrid.execute(@scorecard, @parsed_date)

    respond_to do |format|
      format.html
      format.csv do
        checklist_items = @scorecard.checklist_items
                                    .joins(initiative: :scorecard, characteristic: :focus_area)
                                    .order('initiatives.name', 'characteristics.name')
        send_data(
          checklist_items_to_csv(checklist_items),
          filename: "#{@scorecard.name.parameterize}-comments-#{Date.current}.csv"
        )
      end
    end
  end

  def new
    @impact_card = current_workspace.scorecards.build

    authorize(@impact_card, policy_class: ScorecardPolicy)

    @impact_card.initiatives.build.initiatives_organisations.build
    @impact_card.initiatives.first.initiatives_subsystem_tags.build
  end

  def edit
    # source_scorecard = @scorecard
    # target_scorecard = @scorecard.linked_scorecard

    # @linked_initiatives = build_linked_intiatives(source_scorecard, target_scorecard)
  end

  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @impact_card = current_workspace.scorecards.build(impact_card_params)
    authorize(@impact_card, policy_class: ScorecardPolicy)

    if @impact_card.save
      update_stakeholders!(@impact_card.initiatives.first, initiatives_organisations_params)
      update_subsystem_tags!(@impact_card.initiatives.first, initiatives_subsystem_tags_params)

      if params[:impact_card_source_id].present?
        @source_impact_card = current_workspace.scorecards.find(params[:impact_card_source_id])
        copy_initiatives(@impact_card, @source_impact_card) if @source_impact_card.present?
      end

      redirect_to(impact_card_path(@impact_card), notice: "#{@impact_card.model_name.human} was successfully created.")
    else
      render(:new)
    end
  end

  def update
    if @scorecard.update(impact_card_params)
      redirect_to(impact_card_path(@scorecard), notice: "#{@scorecard.model_name.human} was successfully updated.")
    else
      render(:edit)
    end
  end

  def destroy
    initiative_ids = @scorecard.initiatives.pluck(:id)
    notice = "#{@scorecard.model_name.human} was successfully deleted."

    Scorecard.transaction do
      # SMELL: Move all this to an event object - or better, setup up destroy dependencies / callbacks
      ChecklistItem.where(initiative_id: initiative_ids).destroy_all
      InitiativesOrganisation.where(initiative_id: initiative_ids).delete_all
      InitiativesSubsystemTag.where(initiative_id: initiative_ids).delete_all
      Initiative.where(id: initiative_ids).delete_all

      @scorecard.delete
    end

    redirect_to(impact_cards_path, notice: notice)
  end

  def import_comments # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    authorize(@scorecard, :update?, policy_class: ScorecardPolicy)

    if request.get?
      # Show the import form
      render 'import_comments'
    elsif params[:csv_file].present?
      begin
        import_result = import_checklist_items_from_csv(params[:csv_file], @scorecard)

        message_parts = []
        if import_result[:updated].positive?
          message_parts << "Successfully updated #{import_result[:updated]} checklist items."
        end

        if import_result[:skipped].positive?
          message_parts << "#{import_result[:skipped]} items were skipped (not found or no changes)."
        end

        if import_result[:invalid_status_errors].positive?
          message_parts << "#{import_result[:invalid_status_errors]} items had invalid status values."
        end

        message_parts << "#{import_result[:errors].size} other errors occurred." if import_result[:errors].any?

        redirect_to impact_card_path(@scorecard), notice: message_parts.join(' ')
      rescue StandardError => e
        redirect_to import_comments_impact_card_path(@scorecard), alert: "Import failed: #{e.message}"
      end
    else
      redirect_to import_comments_impact_card_path(@scorecard), alert: 'Please select a CSV file to upload.'
    end
  end

  def shared; end

  def show_shared_link
    render(layout: false)
  end

  private

  def fetch_legend_items(impact_card)
    FocusArea
      .per_data_model(impact_card.data_model_id)
      .joins(:focus_area_group)
      .order('focus_area_groups.position, focus_areas.position')
      .map { |focus_area| { label: focus_area.name, color: focus_area.color } }
  end

  def copy_initiatives(target_impact_card, source_impact_card)
    existing_initiative_names = target_impact_card.initiatives.pluck(:name)

    source_impact_card.initiatives.where.not(name: existing_initiative_names).find_each do |source_initiative|
      target_initiative = source_initiative.dup
      target_initiative.scorecard = target_impact_card
      target_initiative.organisations = source_initiative.organisations
      target_initiative.subsystem_tags = source_initiative.subsystem_tags
      target_initiative.save!
    end
  end

  def merge_cards(impact_card, other_impact_card, deep: false)
    if deep
      ImpactCards::DeepMerge.call(impact_card:, other_impact_card:)
    else
      impact_card.merge(other_impact_card)
    end
  end

  def set_scorecard
    @scorecard = current_workspace.scorecards.find(params[:id])
    authorize(@scorecard, policy_class: ScorecardPolicy)
  end

  def impact_card_params # rubocop:disable Metrics/MethodLength
    params.require(:impact_card).permit(
      :type,
      :name,
      :description,
      :notes,
      :community_id,
      :wicked_problem_id,
      :linked_scorecard_id,
      :share_ecosystem_map,
      :share_thematic_network_map,
      :data_model_id,
      initiatives_attributes: %i[
        _destroy
        name
        description
        started_at
        finished_at
        dates_confirmed
        contact_name
        contact_email
        contact_phone
        contact_website
        contact_position
        notes
      ] # TODO: Remove duplicated initiatives_organisations_attributes / initiatives_subsystem_tags_attributes
    )
  end

  def scorecard_params # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    params.require(impact_card_param).permit( # rubocop:disable Metrics/BlockLength
      :name,
      :description,
      :notes,
      :linked_scorecard_id,
      :share_ecosystem_map,
      :share_thematic_network_map,
      initiatives_attributes: [
        :_destroy,
        :name,
        :description,
        :scorecard_id,
        :started_at,
        :finished_at,
        :archived_on,
        :dates_confirmed,
        :contact_name,
        :contact_email,
        :contact_phone,
        :contact_website,
        :contact_position,
        :notes,
        :type,
        {
          initiatives_organisations_attributes: %i[
            _destroy
            organisation_id
          ],
          initiatives_subsystem_tags_attributes: %i[
            _destroy
            subsystem_tag_id
          ]
        }
      ]
    ).tap do |params| # NOTE: Dupe of code in initiatives controller
      params[:type] = scorecard_class_name

      if params[:initiatives_attributes].present?
        params[:initiatives_attributes].each_key do |initiative_key|
          next if params.dig(:initiatives_attribute, initiative_key, :initiatives_organisations_attributes).blank?

          params[:initiatives_attributes][initiative_key][:initiatives_organisations_attributes].reject! do |key, value|
            value[:_destroy] != '1' && (
              value[:organisation_id].blank? || (
                value[:id].blank? &&
                params[:initiatives_attributes][initiative_key][:initiatives_organisations_attributes].to_h.any? do |selected_key, selected_value| # rubocop:disable Layout/LineLength
                  selected_key != key &&
                  selected_value[:_destroy] != '1' &&
                  selected_value[:organisation_id] == value[:organisation_id]
                end
              )
            )
          end
        end
      end

      if params[:initiatives_attributes].present?
        params[:initiatives_attributes].each_key do |initiative_key|
          next if params.dig(
            :initiatives_attributes,
            initiative_key,
            :initiatives_subsystem_tags_attributes
          ).blank?

          params[:initiatives_attributes][initiative_key][:initiatives_subsystem_tags_attributes].reject! do |key, value| # rubocop:disable Layout/LineLength
            value[:_destroy] != '1' && (
              value[:subsystem_tag_id].blank? || (
                value[:id].blank? &&
                params[:initiatives_attributes][initiative_key][:initiatives_subsystem_tags_attributes].to_h.any? do |selected_key, selected_value| # rubocop:disable Layout/LineLength
                  selected_key != key &&
                  selected_value[:_destroy] != '1' &&
                  selected_value[:subsystem_tag_id] == value[:subsystem_tag_id]
                end
              )
            )
          end
        end
      end
    end
  end

  def checklist_items_to_csv(checklist_items) # rubocop:disable Metrics/MethodLength
    CSV.generate(headers: true) do |csv|
      csv << %w[initiative_name characteristic_name status comment]

      checklist_items.each do |item|
        csv << [
          item.initiative.name,
          item.characteristic.name,
          item.status,
          item.comment
        ]
      end
    end
  end

  def import_checklist_items_from_csv(file, scorecard) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    updated_count = 0
    errors = []
    skipped_count = 0
    invalid_status_errors = 0

    # Valid status values
    valid_statuses = ChecklistItem.statuses.keys - ['no_comment']

    CSV.foreach(file.path, headers: true, force_quotes: true) do |row| # rubocop:disable Metrics/BlockLength
      # Skip empty rows
      next if row['initiative_name'].blank? || row['characteristic_name'].blank?

      # Skip rows with 'no_comment' status (nothing meaningful to import)
      if row['status']&.strip&.downcase == 'no_comment'
        skipped_count += 1
        next
      end

      # Find the checklist item by initiative name and characteristic name within this specific scorecard
      checklist_item = find_checklist_item_by_names_in_scorecard(
        row['initiative_name']&.strip,
        row['characteristic_name']&.strip,
        scorecard
      )

      unless checklist_item
        skipped_count += 1
        next
      end

      # Validate status if provided
      new_status = row['status']&.strip&.downcase
      if new_status.present? && !valid_statuses.include?(new_status)
        invalid_status_errors += 1
        errors << "Row #{$INPUT_LINE_NUMBER}: Invalid status '#{new_status}'. Valid values: #{valid_statuses.join(', ')}" # rubocop:disable Layout/LineLength
        next
      end

      # Check if there are actual changes to make
      new_comment = row['comment']&.strip
      changes_to_make = false

      changes_to_make = true if new_status.present? && checklist_item.status != new_status

      changes_to_make = true if new_comment.present? && checklist_item.comment != new_comment

      unless changes_to_make
        skipped_count += 1
        next
      end

      # Store old values for change tracking
      old_status = checklist_item.status

      # Update the checklist item
      update_attributes = {}
      update_attributes[:status] = new_status if new_status.present?
      update_attributes[:comment] = new_comment if new_comment.present?
      update_attributes[:user] = current_user

      if checklist_item.update(update_attributes)
        # Create change record for audit trail
        checklist_item.checklist_item_changes.create!(
          user: current_user,
          starting_status: old_status,
          ending_status: checklist_item.status,
          comment: checklist_item.comment,
          action: 'import',
          activity: determine_activity(old_status, checklist_item.status)
        )

        updated_count += 1
      else
        errors << "Row #{$INPUT_LINE_NUMBER}: #{checklist_item.errors.full_messages.join(', ')}"
      end
    end

    {
      updated: updated_count,
      errors: errors,
      skipped: skipped_count,
      invalid_status_errors: invalid_status_errors
    }
  end

  def find_checklist_item_by_names_in_scorecard(initiative_name, characteristic_name, scorecard)
    # Find checklist item by initiative name and characteristic name within this specific scorecard
    ChecklistItem.joins(:initiative, :characteristic)
                 .where(initiatives: { scorecard: scorecard })
                 .where('LOWER(initiatives.name) = ?', initiative_name.downcase)
                 .where('LOWER(characteristics.name) = ?', characteristic_name.downcase)
                 .first
  end

  def determine_activity(old_status, new_status)
    if old_status != 'actual' && new_status == 'actual'
      'addition'
    elsif old_status == 'actual' && new_status != 'actual'
      'removal'
    else
      'update'
    end
  end
end
# rubocop:enable Metrics/ClassLength

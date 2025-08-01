# frozen_string_literal: true

# Controller for the Initiative model
# rubocop:disable Metrics/ClassLength
require 'English'
class InitiativesController < ApplicationController # rubocop:disable Style/Documentation
  include VerifyPolicies
  include InitiativeChildRecords

  before_action :set_initiative, only: %i[show edit update destroy]
  before_action :set_focus_area_groups, only: [:show]
  before_action :set_scorecards, only: %i[show new edit]
  before_action :set_subsystem_tags, only: %i[index show]

  sidebar_item :initiatives

  def index # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(Initiative).order(:name).ransack(search_params[:q])

    initiatives = @q.result(distinct: true)

    @pagy, @initiatives = pagy(initiatives, limit: 10)

    respond_to do |format|
      format.html { render 'initiatives/index', locals: { initiatives: @initiatives } }
      format.turbo_stream { render 'initiatives/index', locals: { initiatives: @initiatives } }
      format.csv do
        all_initiatives =
          policy_scope(Initiative)
          .order('lower(initiatives.name)')
          .includes(:scorecard, :subsystem_tags, :organisations)

        send_data(initiatives_to_csv(all_initiatives), type: Mime[:csv], filename: "#{export_filename}.csv")
      end
    end
  end

  def show
    @grouped_checklist_items = @initiative.checklist_items_ordered_by_ordered_focus_area
    @initiative.create_missing_checklist_items!
  end

  def new
    @impact_card = Scorecard.find_by(id: params[:impact_card_id])
    @initiative = Initiative.new(scorecard: @impact_card)

    @initiative.initiatives_organisations.build if @initiative.initiatives_organisations.empty?
    @initiative.initiatives_subsystem_tags.build if @initiative.initiatives_subsystem_tags.empty?

    authorize(@initiative)
  end

  def edit
    @impact_card = @initiative.scorecard

    @initiative.initiatives_organisations.build if @initiative.initiatives_organisations.empty?
    @initiative.initiatives_subsystem_tags.build if @initiative.initiatives_subsystem_tags.empty?
  end

  def create # rubocop:disable Metrics/MethodLength
    @impact_card = Scorecard.find_by(id: params[:impact_card_id])
    authorize(@impact_card, :show?)
    @initiative = @impact_card.initiatives.new(initiative_params)

    authorize(@initiative)

    if @initiative.save
      update_stakeholders!(@initiative, initiatives_organisations_params)
      update_subsystem_tags!(@initiative, initiatives_subsystem_tags_params)

      redirect_to(impact_card_path(@impact_card), notice: 'Initiative was successfully created.')
    else
      render(:new)
    end
  end

  def update
    if @initiative.update(initiative_params)
      update_stakeholders!(@initiative, initiatives_organisations_params)
      update_subsystem_tags!(@initiative, initiatives_subsystem_tags_params)

      # TODO: Put some smarts in here to redirect to the impact cards page if the user was on the impact cards page
      #      when they clicked the edit button, and to the initiative show page if they were on the initiatives page
      redirect_to(initiative_path(@initiative), notice: 'Initiative was successfully updated.')
    else
      render(:edit)
    end
  end

  def destroy
    @initiative.destroy
    redirect_to(initiatives_path, notice: 'Initiative was successfully deleted.')
  end

  def import # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    authorize Initiative
    return unless request.post?

    if params[:csv_file].present?
      begin
        import_result = import_initiatives_from_csv(params[:csv_file])

        message_parts = ["Successfully imported #{import_result[:created]} initiatives."]

        if import_result[:duplicates].positive?
          message_parts << "#{import_result[:duplicates]} initiatives already exist and were skipped."
        end

        if import_result[:scorecard_errors].positive?
          message_parts << "#{import_result[:scorecard_errors]} initiatives had invalid impact cards."
        end

        message_parts << "#{import_result[:errors].size} other errors occurred." if import_result[:errors].any?

        redirect_to initiatives_path, notice: message_parts.join(' ')
      rescue StandardError => e
        redirect_to import_initiatives_path, alert: "Import failed: #{e.message}"
      end
    else
      redirect_to import_initiatives_path, alert: 'Please select a CSV file to upload.'
    end
  end

  # NOTE: Will move this to the checklist controller, where it belongs
  def edit_checklist_item
    @checklist_item = ChecklistItem.find(params[:id])
    authorize(@checklist_item)
    render(partial: 'checklist_item_form', locals: { checklist_item: @checklist_item })
  end

  def linked
    initiative = policy_scope(Initiative).find(params[:initiative_id]).linked_initiative

    authorize(initiative, :show?)

    redirect_to(initiative_path(initiative))
  end

  private

  def export_filename
    "initiatives-#{Time.zone.today.strftime('%Y-%m-%d')}"
  end

  def initiatives_to_csv(initiatives) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    max_organisation_index = initiatives.map(&:organisations).map(&:count).max
    max_subsystem_tag_index = initiatives.map(&:subsystem_tags).map(&:count).max

    CSV.generate(force_quotes: true) do |csv| # rubocop:disable Metrics/BlockLength
      csv << (([
        'Name',
        'Description',
        'Impact Card Name',
        'Impact Card Type',
        'Started At',
        'Finished At',
        'Contact Name',
        'Contact Email',
        'Contact Phone',
        'Contact Website',
        'Contact Position'
      ] + 1.upto(max_organisation_index).map do |index|
        "Stakeholder #{index} Name"
      end + 1.upto(max_subsystem_tag_index).map do |index|
        "Subsystem Tag #{index} Name"
      end) + ['Notes'])

      initiatives.each do |initiative|
        organisations = initiative.organisations.limit(max_organisation_index)
        organisation_memo = Array.new(max_organisation_index, '')

        organisation_names =
          organisations.each_with_index.each_with_object(organisation_memo) do |(org, index), memo|
            memo[index] = org.try(:name)
          end

        subsystem_tags = initiative.subsystem_tags.limit(max_subsystem_tag_index)
        subsystem_tag_memo = Array.new(max_subsystem_tag_index, '')

        subsystem_tag_names =
          subsystem_tags.each_with_index.each_with_object(subsystem_tag_memo) do |(subsystem_tag, index), memo|
            memo[index] = subsystem_tag.try(:name)
          end

        csv << ([
          initiative.name,
          initiative.description,
          initiative.scorecard&.name,
          initiative.scorecard&.model_name&.human,
          initiative.started_at&.strftime('%Y-%m-%d'),
          initiative.finished_at&.strftime('%Y-%m-%d'),
          initiative.contact_name,
          initiative.contact_email,
          initiative.contact_phone,
          initiative.contact_website,
          initiative.contact_position
        ] + organisation_names + subsystem_tag_names + [initiative.notes.to_plain_text.tr("\n", ' ')])
      end
    end
  end

  def set_focus_area_groups
    @focus_areas_groups = \
      @initiative
      .scorecard
      .data_model
      .focus_area_groups
      .includes(:focus_areas)
      .order(:position)
  end

  def set_initiative
    @initiative = Initiative.find(params[:id])
    authorize(@initiative)
  end

  # SMELL: Duplication of code in reports_controller
  ScorecardType = Struct.new('ScorecardType', :name, :scorecards)

  def set_scorecards
    @scorecards = policy_scope(Scorecard).order(:name)
  end

  def set_subsystem_tags
    @subsystem_tags = current_workspace.subsystem_tags
  end

  def initiative_params # rubocop:disable Metrics/MethodLength
    params.fetch(:initiative, {}).permit(
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
      :notes
    )
  end

  def import_initiatives_from_csv(file) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    require 'csv'

    created_count = 0
    errors = []
    duplicate_count = 0
    scorecard_errors = 0
    scorecards_cache = {}

    # Build cache of scorecards for faster lookup
    policy_scope(Scorecard).each do |sc|
      scorecards_cache[sc.name.downcase] = sc
    end

    CSV.foreach(file.path, headers: true, force_quotes: true) do |row| # rubocop:disable Metrics/BlockLength
      # Skip empty rows
      next if row['Name'].blank? || row['Name'].strip.empty?

      scorecard = nil
      if row['Impact Card Name'].present?
        scorecard = scorecards_cache[row['Impact Card Name'].downcase]
        unless scorecard
          scorecard_errors += 1
          errors << "Row #{$INPUT_LINE_NUMBER}: Impact card '#{row['Impact Card Name']}' not found"
          next
        end
      end

      # Parse dates
      started_at = nil
      finished_at = nil

      begin
        started_at = Date.parse(row['Started At']) if row['Started At'].present?
      rescue Date::Error
        # Ignore invalid dates
      end

      begin
        finished_at = Date.parse(row['Finished At']) if row['Finished At'].present?
      rescue Date::Error
        # Ignore invalid dates
      end

      # Check if initiative already exists with same name in same scorecard
      if scorecard&.initiatives&.exists?(name: row['Name']&.strip)
        duplicate_count += 1
        next
      end

      initiative = Initiative.new(
        name: row['Name']&.strip,
        description: row['Description']&.strip,
        scorecard: scorecard,
        started_at: started_at,
        finished_at: finished_at,
        contact_name: row['Contact Name']&.strip,
        contact_email: row['Contact Email']&.strip,
        contact_phone: row['Contact Phone']&.strip,
        contact_website: row['Contact Website']&.strip,
        contact_position: row['Contact Position']&.strip,
        notes: row['Notes']&.strip
      )

      authorize initiative

      if initiative.save
        created_count += 1
      else
        errors << "Row #{$INPUT_LINE_NUMBER}: #{initiative.errors.full_messages.join(', ')}"
      end
    end

    {
      created: created_count,
      errors: errors,
      duplicates: duplicate_count,
      scorecard_errors: scorecard_errors
    }
  end
end
# rubocop:enable Metrics/ClassLength

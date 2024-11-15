# frozen_string_literal: true

# Controller for the Initiative model
# rubocop:disable Metrics/ClassLength
class InitiativesController < ApplicationController
  include VerifyPolicies

  before_action :set_initiative, only: %i[show edit update destroy]
  before_action :set_focus_area_groups, only: [:show]
  before_action :set_scorecards_and_types, only: %i[show new edit]

  sidebar_item :initiatives

  def index # rubocop:disable Metrics/AbcSize
    @subsystem_tags = current_account.subsystem_tags

    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(Initiative).order(:name).ransack(search_params[:q])

    initiatives = @q.result(distinct: true)

    @pagy, @initiatives = pagy(initiatives, limit: 10)

    respond_to do |format|
      format.html { render 'initiatives/index', locals: { initiatives: @initiatives } }
      format.turbo_stream { render 'initiatives/index', locals: { initiatives: @initiatives } }
      format.csv { send_data(initiatives_to_csv(@initiatives), type: Mime[:csv], filename: "#{export_filename}.csv") }
    end
  end

  def show
    sidebar_item :impact_cards

    @grouped_checklist_items = @initiative.checklist_items_ordered_by_ordered_focus_area
    @initiative.create_missing_checklist_items!
  end

  def new
    @scorecard = params[:scorecard_id].present? ? policy_scope(Scorecard).find(params[:scorecard_id]) : nil
    @initiative = Initiative.new(scorecard: @scorecard)
    authorize(@initiative)
  end

  def edit
    @initiative.initiatives_organisations.build if @initiative.initiatives_organisations.empty?
    @initiative.initiatives_subsystem_tags.build if @initiative.initiatives_subsystem_tags.empty?
  end

  def create
    @initiative = Initiative.new(initiative_params)
    authorize(@initiative)

    if @initiative.save
      ::SynchronizeLinkedInitiative.call(@initiative) if @initiative.scorecard.linked?

      redirect_to(initiatives_path, notice: 'Initiative was successfully created.')
    else
      render(:new)
    end
  end

  def update # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    linked_initiative = @initiative.linked_initiative

    if @initiative.update(initiative_params)
      update_stakeholders!(@initiative, initiatives_organisations_params)
      update_subsystem_tags!(@initiative, initiatives_subsystem_tags_params)

      if params[:unlink_initiative]
        linked_initiative.update(linked: false) if linked_initiative.present?
        @initiative.update(linked: false)
      elsif @initiative.linked?
        ::SynchronizeLinkedInitiative.call(@initiative, linked_initiative)
      end

      # TODO: Put some smarts in here to redirect to the impact cards page if the user was on the impact cards page
      #      when they clicked the edit button, and to the initiative show page if they were on the initiatives page
      redirect_to(initiatives_path, notice: 'Initiative was successfully updated.')
    else
      render(:edit)
    end
  end

  def destroy
    @initiative.destroy
    redirect_to(initiatives_path, notice: 'Initiative was successfully deleted.')
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
    if current_account.scorecard_types.count > 1
      "initiatives_for_#{scope_from_params}_#{Time.zone.today.strftime('%Y_%m_%d')}"
    else
      "initiatives_#{Time.zone.today.strftime('%Y_%m_%d')}"
    end
  end

  def initiatives_to_csv(initiatives) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    max_organisation_index = initiatives.map(&:organisations).map(&:count).max
    max_subsystem_tag_index = initiatives.map(&:subsystem_tags).map(&:count).max

    CSV.generate(force_quotes: true) do |csv| # rubocop:disable Metrics/BlockLength
      csv << (([
        'Name',
        'Description',
        "#{Scorecard.model_name.human} Name",
        'Started At',
        'Finished At',
        'Contact Name',
        'Contact Email',
        'Contact Phone',
        'Contact Website',
        'Contact Position'
      ] + 1.upto(max_organisation_index).map do |index|
        "Organisation #{index} Name"
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
          initiative.scorecard.try(:name),
          initiative.started_at,
          initiative.finished_at,
          initiative.contact_name,
          initiative.contact_email,
          initiative.contact_phone,
          initiative.contact_website,
          initiative.contact_position
        ] + organisation_names + subsystem_tag_names + [initiative.notes.to_plain_text.gsub("\n", ' ')])
      end
    end
  end

  def set_focus_area_groups
    @focus_areas_groups = \
      FocusAreaGroup
      .includes(:video_tutorial, focus_areas: :video_tutorial)
      .where(scorecard_type: @initiative.scorecard.type, account_id: @initiative.scorecard.account_id)
      .order(:position)
  end

  def set_initiative
    @initiative = Initiative.find(params[:id])
    authorize(@initiative)
  end

  def scope_from_params # rubocop:disable Metrics/AbcSize
    if params[:scope].blank? || !params[:scope].in?(%w[transition_cards sdgs_alignment_cards])
      case current_account.default_scorecard_type&.name
      when 'TransitionCard' then :transition_cards
      when 'SustainableDevelopmentGoalAlignmentCard' then :sdgs_alignment_cards
      else
        raise("Unknown scorecard_type.name '#{current_account.default_scorecard_type.name}'")
      end
    else
      params[:scope].to_sym
    end
  end

  # SMELL: Duplication of code in reports_controller
  ScorecardType = Struct.new('ScorecardType', :name, :scorecards)

  def set_scorecards_and_types
    @scorecards = policy_scope(Scorecard).order(:name)

    @scorecard_types =
      current_account.scorecard_types.map do |scorecard_type|
        ScorecardType.new(
          scorecard_type.model_name.human.pluralize,
          policy_scope(Scorecard).order(:name).where(type: scorecard_type.name)
        )
      end
  end

  def initiatives_organisations_params
    params.fetch(:initiative, {}).permit(
      {
        initiatives_organisations_attributes: %i[
          organisation_id
        ]
      }
    )
  end

  def initiatives_subsystem_tags_params
    params.fetch(:initiative, {}).permit(
      {
        initiatives_subsystem_tags_attributes: %i[
          subsystem_tag_id
        ]
      }
    )
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

  def update_stakeholders!(initiative, params)
    initiative.initiatives_organisations.destroy_all

    params[:initiatives_organisations_attributes].each_value do |organisation_params|
      initiative.initiatives_organisations.create(organisation_params)
    end
  end

  def update_subsystem_tags!(initiative, params)
    initiative.initiatives_subsystem_tags.destroy_all

    params[:initiatives_subsystem_tags_attributes].each_value do |subsystem_tag_params|
      initiative.initiatives_subsystem_tags.create(subsystem_tag_params)
    end
  end
end
# rubocop:enable Metrics/ClassLength

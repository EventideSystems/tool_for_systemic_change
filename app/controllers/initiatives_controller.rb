# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class InitiativesController < ApplicationController
  before_action :set_initiative, only: %i[show edit update destroy]
  before_action :set_focus_area_groups, only: [:show]
  before_action :set_scorecards_and_types, only: %i[show new edit]

  add_breadcrumb 'Initiatives', :initiatives_path

  def index
    base_scope = policy_scope(Initiative).send(scope_from_params).includes(:organisations).order(sort_order)

    respond_to do |format|
      format.html do
        @initiatives = base_scope.page params[:page]
      end
      format.csv do
        @initiatives = base_scope.all
        send_data initiatives_to_csv(@initiatives), type: Mime[:csv], filename: "#{export_filename}.csv"
      end
    end
  end

  def show
    @grouped_checklist_items = @initiative.checklist_items_ordered_by_ordered_focus_area

    add_breadcrumb @initiative.name
  end

  def new
    @scorecard = params[:scorecard_id].present? ? policy_scope(Scorecard).find(params[:scorecard_id]) : nil
    @initiative = Initiative.new(scorecard: @scorecard)
    authorize @initiative

    add_breadcrumb 'New Initiative'
  end

  def edit
    add_breadcrumb @initiative.name
  end

  def create
    @initiative = Initiative.new(initiative_params)
    authorize @initiative

    if @initiative.save
      ::SynchronizeLinkedInitiative.call(@initiative) if @initiative.scorecard.linked?

      redirect_to initiatives_path, notice: 'Initiative was successfully created.'
    else
      render :new
    end

  end

  def update
    linked_initiative = @initiative.linked_initiative

    if @initiative.update(initiative_params)
      if params[:unlink_initiative]
        linked_initiative.update(linked: false) if linked_initiative.present?
        @initiative.update(linked: false)
      elsif @initiative.linked?
        ::SynchronizeLinkedInitiative.call(@initiative, linked_initiative)
      end

      redirect_to initiatives_path, notice: 'Initiative was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @initiative.destroy
    redirect_to initiatives_url, notice: 'Initiative was successfully deleted.'
  end

  def content_subtitle
    subtitle = (@initiative&.name.presence || super)

    @initiative&.archived? ? subtitle + ' [ARCHIVED]' : subtitle
  end

  # NOTE Will move this to the checklist controller, where it belongs
  def edit_checklist_item
    @checklist_item = ChecklistItem.find(params[:id])
    authorize @checklist_item
    render partial: 'checklist_item_form', locals: { checklist_item: @checklist_item }
  end

  def linked
    initiative = policy_scope(Initiative).find(params[:initiative_id]).linked_initiative

    authorize initiative, :show?

    redirect_to initiative_path(initiative)
  end

  private

  def export_filename
    if current_account.scorecard_types.count > 1
      "initiatives_for_#{scope_from_params}_#{Date.today.strftime('%Y_%m_%d')}"
    else
      "initiatives_#{Date.today.strftime('%Y_%m_%d')}"
    end
  end

  def initiatives_to_csv(initiatives)
    max_organisation_index = initiatives.map(&:organisations).map(&:count).max
    max_subsystem_tag_index = initiatives.map(&:subsystem_tags).map(&:count).max

    CSV.generate(force_quotes: true) do |csv|
      csv << ([
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
      end)

      initiatives.each do |initiative|
        organisations = initiative.organisations.limit(max_organisation_index)
        organisation_memo = Array.new(max_organisation_index, '')

        organisation_names = organisations.each_with_index.each_with_object(organisation_memo) do |(org, index), memo|
          memo[index] = org.try(:name)
        end

        subsystem_tags = initiative.subsystem_tags.limit(max_subsystem_tag_index)
        subsystem_tag_memo = Array.new(max_subsystem_tag_index, '')

        subsystem_tag_names = subsystem_tags.each_with_index.each_with_object(subsystem_tag_memo) do |(subsystem_tag, index), memo|
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
        ] + organisation_names + subsystem_tag_names)
      end
    end
  end

  def set_focus_area_groups
    @focus_areas_groups = FocusAreaGroup
                          .includes(:video_tutorial, focus_areas: :video_tutorial)
                          .where(scorecard_type: @initiative.scorecard.type)
                          .order(:position)
  end

  def set_initiative
    @initiative = Initiative.find(params[:id])
    authorize @initiative
  end

  def scope_from_params
    if params[:scope].blank? || !params[:scope].in?(%w[transition_cards sdgs_alignment_cards])
      case current_account.default_scorecard_type&.name
      when 'TransitionCard' then :transition_cards
      when 'SustainableDevelopmentGoalAlignmentCard' then :sdgs_alignment_cards
      else
        raise "Unknown scorecard_type.name '#{current_account.default_scorecard_type.name}'"
      end
    else
      params[:scope].to_sym
    end
  end

  # SMELL: Duplication of code in reports_controller
  ScorecardType = Struct.new('ScorecardType', :name, :scorecards)

  def set_scorecards_and_types
    @scorecards = policy_scope(Scorecard).order(:name)

    @scorecard_types = current_account.scorecard_types.map do |scorecard_type|
      ScorecardType.new(
        scorecard_type.model_name.human.pluralize,
        policy_scope(Scorecard).order(:name).where(type: scorecard_type.name)
      )
    end
  end

  def initiative_params
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
      :notes,
      initiatives_organisations_attributes: %i[
        organisation_id id _destroy
      ],
      initiatives_subsystem_tags_attributes: %i[
        subsystem_tag_id id _destroy
      ]
    ).tap do |params|
      # Remove organisations that are already assigned
      params[:initiatives_organisations_attributes].reject! do |_key, value|
        value[:id].blank? &&
          params[:initiatives_organisations_attributes].values.find do |attributes|
            (value[:organisation_id] == attributes[:organisation_id]) &&
              attributes[:id].present?
          end
      end

      # Remove duplicates
      params[:initiatives_organisations_attributes] = ActionController::Parameters.new(
        params[:initiatives_organisations_attributes].to_h.invert.invert
      ).permit!

      # Remove subsystem tags that are already assigned
      params[:initiatives_subsystem_tags_attributes].reject! do |_key, value|
        value[:id].blank? &&
          params[:initiatives_subsystem_tags_attributes].values.find do |attributes|
            (value[:subsystem_tag_id] == attributes[:subsystem_tag_id]) &&
              attributes[:id].present?
          end
      end

      # Remove duplicates
      params[:initiatives_subsystem_tags_attributes] = ActionController::Parameters.new(
        params[:initiatives_subsystem_tags_attributes].to_h.invert.invert
      ).permit!
    end
  end
end
# rubocop:enable Metrics/ClassLength

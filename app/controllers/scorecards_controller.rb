# frozen_string_literal: true

class ScorecardsController < ApplicationController
  before_action :set_scorecard,
                only: %i[
                  show edit update destroy
                  show_shared_link copy copy_options merge merge_options
                  ecosystem_maps_organisations
                  activities
                ]

  before_action :set_active_tab, only: [:show]
  before_action :require_account_selected, only: %i[new create edit update show_shared_link]
  before_action :redirect_to_correct_controller, only: %i[show]

  def show
    @selected_date = params[:selected_date]
    @parsed_selected_date = @selected_date.blank? ? nil : Date.parse(@selected_date)

    @selected_tags = if params[:selected_tags].blank?
                       []
                     else
                       SubsystemTag.where(account: current_account,
                                          name: params[:selected_tags])
                     end

    @focus_areas = FocusArea
                   .joins(:focus_area_group)
                   .where(focus_area_groups: { scorecard_type: @scorecard.type })
                   .ordered_by_group_position

    @characteristics = Characteristic
                       .includes(focus_area: :focus_area_group)
                       .per_scorecard_type(@scorecard.type)
                       .order('focus_areas.position, characteristics.position')

    source_scorecard = @scorecard
    target_scorecard = @scorecard.linked_scorecard

    @linked_initiatives = build_linked_intiatives(source_scorecard, target_scorecard)

    @results = ScorecardGrid.execute(@scorecard, @parsed_selected_date, @selected_tags)

    add_breadcrumb @scorecard.name

    respond_to do |format|
      format.html
      format.pdf do
        # TODO: Convert PDF to use transition card summary data
        @initiatives = if @parsed_selected_date.present?
                         @scorecard.initiatives
                                   .where('started_at <= ? OR started_at IS NULL', @parsed_selected_date)
                                   .where('finished_at >= ? OR finished_at IS NULL', @parsed_selected_date)
                                   .order(name: :asc)
                       else
                         @scorecard.initiatives.order(name: :asc)
                       end

        @initiatives = if @selected_tags.present?
                         tag_ids = @selected_tags.map(&:id)
                         @initiatives
                           .distinct
                           .joins(:initiatives_subsystem_tags)
                           .where('initiatives_subsystem_tags.subsystem_tag_id' => tag_ids)
                           .select('initiatives.*, lower(initiatives.name)')
                       else
                         @initiatives
                       end

        pdf = ScorecardPdfGenerator.new(
          scorecard: @scorecard,
          initiatives: @initiatives,
          focus_areas: @focus_areas
        ).perform
        send_data pdf.render,
                  filename: "transition_card_#{@scorecard.id}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def new
    @scorecard = current_account.scorecards.build(type: scorecard_class_name)
    authorize @scorecard, policy_class: ScorecardPolicy

    @scorecard.initiatives.build

    add_breadcrumb 'New'
  end

  def edit
    add_breadcrumb @scorecard.name

    source_scorecard = @scorecard
    target_scorecard = @scorecard.linked_scorecard

    @linked_initiatives = build_linked_intiatives(source_scorecard, target_scorecard)
  end

  def create
    @scorecard = current_account.scorecards.build(scorecard_params)
    authorize @scorecard, policy_class: ScorecardPolicy

    respond_to do |format|
      if @scorecard.save
        SynchronizeLinkedScorecard.call(@scorecard, linked_initiatives_params)
        format.html { redirect_to @scorecard, notice: "#{@scorecard.model_name.human} was successfully created." }
        format.json { render :show, status: :created, location: @scorecard }
      else
        format.html { render :new }
        format.json { render json: @scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @scorecard.update(scorecard_params)
        if params[:unlink_scorecard]
          @scorecard.linked_scorecard = nil
          @scorecard.update(linked_scorecard: nil)
        end

        SynchronizeLinkedScorecard.call(@scorecard, linked_initiatives_params)

        format.html { redirect_to @scorecard, notice: "#{@scorecard.model_name.human} was successfully updated." }
        format.json { render :show, status: :ok, location: @scorecard }
      else
        format.html { render :edit }
        format.json { render json: @scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    notice = "#{@scorecard.model_name.human} was successfully deleted."

    initiative_ids = @scorecard.initiatives.pluck(:id)

    # SMELL: Move all this to an event object
    ChecklistItem.where(initiative_id: initiative_ids).delete_all
    ChecklistItem.where(initiative_id: initiative_ids).delete_all
    InitiativesOrganisation.where(initiative_id: initiative_ids).delete_all
    InitiativesSubsystemTag.where(initiative_id: initiative_ids).delete_all

    Initiative.where(id: initiative_ids).delete_all

    @scorecard.destroy

    respond_to do |format|
      format.html do
        case @scorecard.class.name
        when 'TransitionCard'
          redirect_to transition_cards_path, notice: notice
        when 'SustainableDevelopmentGoalAlignmentCard'
          redirect_to sustainable_development_goal_alignment_cards_path, notice: notice
        else
          raise "Unknown scorecard type: #{klass.name}"
        end
      end
      format.json { head :no_content }
    end
  end

  def shared; end

  def show_shared_link
    render layout: false
  end

  def copy_options
    render layout: false
  end

  def copy
    new_name = params[:new_name]
    deep_copy = params[:copy] == 'deep'

    @copied_scorecard = ScorecardCopier.new(@scorecard, new_name, deep_copy: deep_copy).perform
    respond_to do |format|
      if @copied_scorecard.present?
        format.html do
          redirect_to @copied_scorecard,
                      notice: "#{@copied_scorecard.model_name.human} was successfully copied."
        end
        format.json { render :show, status: :ok, location: @copied_scorecard }
      else
        format.html { render :edit }
        format.json { render json: @copied_scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  def merge_options
    @other_scorecards = current_account.scorecards.where.not(id: @scorecard.id).order('lower(name)')
    render layout: false
  end

  def merge
    @other_scorecard = current_account.scorecards.find(params[:other_scorecard_id])
    @merged_scorecard = @scorecard.merge(@other_scorecard)
    respond_to do |format|
      if @scorecard.present?
        format.html do
          redirect_to transition_card_path(@merged_scorecard),
                      notice: "#{Scorecard.model_name.human} were successfully merged."
        end
        format.json { render :show, status: :ok, location: @merged_scorecard }
      else
        format.html { render :edit }
        format.json { render json: @merged_scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  def ecosystem_maps_organisations
    data = EcosystemMaps::Organisations.new(@scorecard)

    render json: { data: { nodes: data.nodes, links: data.links } }
  end

  def activities
    @activities = Events::TransitionCardActivity.where(transition_card_id: @scorecard.id).order(occurred_at: :desc)

    render partial: '/scorecards/show_tabs/activities', locals: { activities: @activities }
  end

  def content_subtitle
    return @scorecard.name if @scorecard.present?

    super
  end

  def linked_initiatives
    source_scorecard = current_account.scorecards.find(params[:id])
    target_scorecard = current_account.scorecards.find(params[:target_id])

    authorize source_scorecard, policy_class: ScorecardPolicy
    authorize target_scorecard, policy_class: ScorecardPolicy

    render partial: '/scorecards/show_tabs/linked_initiatives',
           locals: { linked_initiatives: build_linked_intiatives(source_scorecard, target_scorecard) }
  end

  private

  def build_linked_intiatives(source_scorecard, target_scorecard)
    return [] if target_scorecard.blank?

    source_initiatives = source_scorecard.initiatives.each_with_object({}) do |initiative, hash|
      hash[initiative.name] = initiative
    end

    target_initiatives = target_scorecard.initiatives.each_with_object({}) do |initiative, hash|
      hash[initiative.name] = initiative
    end

    all_names = (source_initiatives.keys + target_initiatives.keys).uniq.sort

    all_names.map do |name|
      {
        name: name,
        this_card: source_initiatives[name].present? ? 'Present' : 'Missing',
        linked_card: target_initiatives[name].present? ? 'Present' : 'Missing',
        action: calc_link_action(source_initiatives[name], target_initiatives[name]),
        linked: target_initiatives[name]&.linked? || source_initiatives[name]&.linked?
      }
    end
  end

  def calc_present_in(source_initiative, target_initiative)
    return 'Both' if source_initiative.present? && target_initiative.present?
    return 'This card' if source_initiative.present?

    'Other card'
  end

  def calc_link_action(source_initiative, target_initiative)
    return 'Link existing initatives' if source_initiative.present? && target_initiative.present?
    return 'Copy from this card and link' if source_initiative.present?

    'Copy from other card and link'
  end

  def set_scorecard
    @scorecard = current_account.scorecards.find(params[:id])
    authorize @scorecard, policy_class: ScorecardPolicy
  end

  def set_active_tab
    @active_tab = params[:active_tab]&.to_sym || :scorecard
  end

  def linked_initiatives_params
    params[:linked_initiatives]
  end

  def redirect_to_correct_controller
    case controller_name
    when 'transition_cards'
      if @scorecard.type == 'SustainableDevelopmentGoalAlignmentCard'
        redirect_to sustainable_development_goal_alignment_card_path(@scorecard)
      end
    when 'sustainable_development_goal_alignment_cards'
      redirect_to transition_card_path(@scorecard) if @scorecard.type == 'TransitionCard'
    end
  end

  def scorecard_params
    params[scorecard_key_param][:linked_scorecard_id] = params[:linked_scorecard_id]

    params.require(scorecard_key_param).permit(
      :name,
      :description,
      :wicked_problem_id,
      :community_id,
      :notes,
      :linked_scorecard_id,
      initiatives_attributes: [
        :_destroy,
        :name,
        :description,
        :scorecard_id,
        :started_at,
        :finished_at,
        :dates_confirmed,
        :contact_name,
        :contact_email,
        :contact_phone,
        :contact_website,
        :contact_position,
        :notes,
        :type,
        { initiatives_organisations_attributes: %i[
          _destroy
          organisation_id
        ],
          initiatives_subsystem_tags_attributes: %i[
            _destroy
            subsystem_tag_id
          ] }
      ]
    ).tap do |params| # NOTE: Dupe of code in initiatives controller
      params[:type] = scorecard_class_name

      unless params[:initiatives_attributes].blank?
        params[:initiatives_attributes].each do |initiative_key, _|
          next unless params.dig(:initiatives_attribute, initiative_key, :initiatives_organisations_attributes).present?

          params[:initiatives_attributes][initiative_key][:initiatives_organisations_attributes].reject! do |key, value|
            value[:_destroy] != '1' && (
              value[:organisation_id].blank? || (
                value[:id].blank? &&
                params[:initiatives_attributes][initiative_key][:initiatives_organisations_attributes].to_h.any? do |selected_key, selected_value|
                  selected_key != key &&
                  selected_value[:_destroy] != '1' &&
                  selected_value[:organisation_id] == value[:organisation_id]
                end
              )
            )
          end
        end
      end

      unless params[:initiatives_attributes].blank?
        params[:initiatives_attributes].each do |initiative_key, _|
          next unless params.dig(:initiatives_attributes, initiative_key,
                                 :initiatives_subsystem_tags_attributes).present?

          params[:initiatives_attributes][initiative_key][:initiatives_subsystem_tags_attributes].reject! do |key, value|
            value[:_destroy] != '1' && (
              value[:subsystem_tag_id].blank? || (
                value[:id].blank? &&
                params[:initiatives_attributes][initiative_key][:initiatives_subsystem_tags_attributes].to_h.any? do |selected_key, selected_value|
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
end

# frozen_string_literal: true

# Controller for the ImpactCard model (TransitionCard and SustainableDevelopmentGoalAlignmentCard)
# rubocop:disable Metrics/ClassLength
class ImpactCardsController < ApplicationController
  include VerifyPolicies
  include InitiativeChildRecords

  # SMELL: characteristic is actually in the SustainableDevelopmentGoalAlignmentCardsController. Need to
  # rework this so that it's not in the base class.
  before_action :set_scorecard, except: %i[index new create ecosystem_maps_organisations]

  before_action :set_active_tab, only: [:show]
  before_action :require_account_selected, only: %i[new create edit update show_shared_link]
  before_action :redirect_to_correct_controller, only: %i[show]

  skip_before_action :authenticate_user!, only: %i[ecosystem_maps_organisations]
  skip_after_action :verify_authorized, only: %i[ecosystem_maps_organisations]

  sidebar_item :impact_cards

  def index # rubocop:disable Metrics/AbcSize
    @communities = current_account.communities
    @wicked_problems = current_account.wicked_problems

    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(Scorecard).order(:name).ransack(search_params[:q])

    impact_cards = @q.result(distinct: true)

    @pagy, @impact_cards = pagy(impact_cards, limit: 10)

    respond_to do |format|
      format.html { render 'impact_cards/index', locals: { impact_cards: @impact_cards } }
      format.turbo_stream { render 'impact_cards/index', locals: { impact_cards: @impact_cards } }
    end
  end

  def show # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/PerceivedComplexity
    @selected_date = params[:selected_date]
    @parsed_selected_date = @selected_date.blank? ? nil : Date.parse(@selected_date)

    @selected_tags =
      if params[:selected_tags].blank?
        []
      else
        SubsystemTag.where(account: current_account, name: params[:selected_tags])
      end

    # @focus_areas = FocusArea
    #                .includes(:characteristics)
    #                .joins(:focus_area_group)
    #                .where(focus_area_groups: { scorecard_type: @scorecard.type, account_id: @scorecard.account.id })
    #                .ordered_by_group_position

    # @characteristics = Characteristic
    #                    .includes(focus_area: :focus_area_group)
    #                    .per_scorecard_type_for_account(@scorecard.type, @scorecard.account)
    #                    .order('focus_areas.position, characteristics.position')

    # source_scorecard = @scorecard
    # target_scorecard = @scorecard.linked_scorecard

    # @linked_initiatives = build_linked_intiatives(source_scorecard, target_scorecard)

    @scorecard_grid = ScorecardGrid.execute(@scorecard, @parsed_selected_date, @selected_tags)

    respond_to do |format| # rubocop:disable Metrics/BlockLength
      format.html
      format.pdf do # rubocop:disable Metrics/BlockLength
        # TODO: Convert PDF to use transition card summary data
        @initiatives =
          if @parsed_selected_date.present?
            @scorecard.initiatives
                      .where('archived_on > ? OR archived_on IS NULL', @parsed_selected_date)
                      .where('started_at <= ? OR started_at IS NULL', @parsed_selected_date)
                      .where('finished_at >= ? OR finished_at IS NULL', @parsed_selected_date)
                      .order(name: :asc)
          else
            @scorecard.initiatives.not_archived.order(name: :asc)
          end

        @initiatives =
          if @selected_tags.present?
            tag_ids = @selected_tags.map(&:id)
            @initiatives
              .distinct
              .joins(:initiatives_subsystem_tags)
              .where('initiatives_subsystem_tags.subsystem_tag_id': tag_ids)
              .select('initiatives.*, lower(initiatives.name)')
          else
            @initiatives
          end

        pdf = ScorecardPdfGenerator.new(
          scorecard: @scorecard,
          initiatives: @initiatives,
          focus_areas: @focus_areas
        ).perform
        send_data(
          pdf.render,
          filename: "transition_card_#{@scorecard.id}.pdf",
          type: 'application/pdf',
          disposition: 'inline'
        )
      end
    end
  end

  def new
    @impact_card = current_account.scorecards.build

    authorize(@impact_card, policy_class: ScorecardPolicy)

    @impact_card.initiatives.build.initiatives_organisations.build
    @impact_card.initiatives.first.initiatives_subsystem_tags.build
  end

  def edit
    source_scorecard = @scorecard
    target_scorecard = @scorecard.linked_scorecard

    @linked_initiatives = build_linked_intiatives(source_scorecard, target_scorecard)
  end

  def create # rubocop:disable Metrics/AbcSize
    @impact_card = current_account.scorecards.build(impact_card_params)
    authorize(@impact_card, policy_class: ScorecardPolicy)

    if @impact_card.save
      update_stakeholders!(@impact_card.initiatives.first, initiatives_organisations_params)
      update_subsystem_tags!(@impact_card.initiatives.first, initiatives_subsystem_tags_params)

      redirect_to(impact_card_path(@impact_card), notice: "#{@impact_card.model_name.human} was successfully created.")
    else
      render(:new)
    end
  end

  def update
    if @scorecard.update(scorecard_params)
      if params[:unlink_scorecard]
        @scorecard.linked_scorecard = nil
        @scorecard.update(linked_scorecard: nil)
      end

      SynchronizeLinkedScorecard.call(@scorecard, linked_initiatives_params)

      redirect_to(@scorecard, notice: "#{@scorecard.model_name.human} was successfully updated.")
    else
      render(:edit)
    end
  end

  def destroy # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    notice = "#{@scorecard.model_name.human} was successfully deleted."

    initiative_ids = @scorecard.initiatives.pluck(:id)

    # SMELL: Move all this to an event object - or better, setup up destroy dependencies / callbacks
    ChecklistItem.where(initiative_id: initiative_ids).destroy_all
    InitiativesOrganisation.where(initiative_id: initiative_ids).delete_all
    InitiativesSubsystemTag.where(initiative_id: initiative_ids).delete_all
    Initiative.where(id: initiative_ids).delete_all

    @scorecard.destroy

    case @scorecard.class.name
    when 'TransitionCard'
      redirect_to(transition_cards_path, notice: notice)
    when 'SustainableDevelopmentGoalAlignmentCard'
      redirect_to(sustainable_development_goal_alignment_cards_path, notice: notice)
    else
      raise("Unknown scorecard type: #{klass.name}")
    end
  end

  def shared; end

  def show_shared_link
    render(layout: false)
  end

  def copy_options
    render(layout: false)
  end

  def copy
    new_name = params[:new_name]
    deep_copy = params[:copy] == 'deep'

    @copied_scorecard = ScorecardCopier.new(@scorecard, new_name, deep_copy: deep_copy).perform
    if @copied_scorecard.present?
      redirect_to(@copied_scorecard, notice: "#{@copied_scorecard.model_name.human} was successfully copied.")
    else
      render(:edit)
    end
  end

  def merge_options
    @other_scorecards = \
      current_account.scorecards.where(type: @scorecard.type).where.not(id: @scorecard.id).order('lower(name)')

    render(layout: false)
  end

  def merge # rubocop:disable Metrics/MethodLength
    @other_scorecard = current_account.scorecards.find(params[:other_scorecard_id])
    @merged_scorecard = @scorecard.merge(@other_scorecard)

    if @merged_scorecard.present?
      card_path =
        case @scorecard.type
        when 'TransitionCard'
          transition_card_path(@merged_scorecard)
        when 'SustainableDevelopmentGoalAlignmentCard'
          sustainable_development_goal_alignment_card_path(@merged_scorecard)
        end

      redirect_to(card_path, notice: "#{@scorecard.model_name.human} were successfully merged.")
    else
      format.html { render(:edit) }
    end
  end

  def ecosystem_maps_organisations # rubocop:disable Metrics/AbcSize
    if params[:id].to_s == params[:id].to_i.to_s
      @scorecard = current_account.scorecards.find(params[:id])
      authorize(@scorecard)
    else
      @scorecard = Scorecard.find_by(shared_link_id: params[:id])
    end

    data = EcosystemMaps::Organisations.new(@scorecard)

    render(json: { data: { nodes: data.nodes, links: data.links } })
  end

  def activities
    @activities = @scorecard.scorecard_changes.order(occurred_at: :desc)

    render(partial: '/scorecards/show_tabs/activity', locals: { activities: @activities })
  end

  def linked_initiatives
    source_scorecard = current_account.scorecards.find(params[:id])
    target_scorecard = current_account.scorecards.find(params[:target_id])

    authorize(source_scorecard, policy_class: ScorecardPolicy)
    authorize(target_scorecard, policy_class: ScorecardPolicy)

    render(
      partial: '/scorecards/show_tabs/linked_initiatives',
      locals: { linked_initiatives: build_linked_intiatives(source_scorecard, target_scorecard) }
    )
  end

  private

  def build_linked_intiatives(source_scorecard, target_scorecard) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
    return [] if target_scorecard.blank?

    source_initiatives =
      source_scorecard.initiatives.index_by(&:name)

    target_initiatives =
      target_scorecard.initiatives.index_by(&:name)

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

  def initiatives_organisations_params
    params.fetch(:impact_card, {}).fetch(:initiatives_attributes, {}).fetch('0', {}).permit(
      {
        initiatives_organisations_attributes: %i[
          organisation_id
        ]
      }
    )
  end

  def initiatives_subsystem_tags_params
    params.fetch(:impact_card, {}).fetch(:initiatives_attributes, {}).fetch('0', {}).permit(
      {
        initiatives_subsystem_tags_attributes: %i[
          subsystem_tag_id
        ]
      }
    )
  end

  def set_scorecard
    @scorecard = current_account.scorecards.find(params[:id])
    authorize(@scorecard, policy_class: ScorecardPolicy)
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
        redirect_to(sustainable_development_goal_alignment_card_path(@scorecard))
      end
    when 'sustainable_development_goal_alignment_cards'
      redirect_to(transition_card_path(@scorecard)) if @scorecard.type == 'TransitionCard'
    end
  end

  def impact_card_params # rubocop:disable Metrics/MethodLength
    params.require(:impact_card).permit(
      :type,
      :name,
      :description,
      :notes,
      :linked_scorecard_id,
      :share_ecosystem_map,
      :share_thematic_network_map,
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
    params[scorecard_key_param][:linked_scorecard_id] = params[:linked_scorecard_id]

    params[scorecard_key_param].delete(:share_ecosystem_map) unless policy(Scorecard).share_ecosystem_maps?
    unless policy(Scorecard).share_thematic_network_maps?
      params[scorecard_key_param].delete(:share_thematic_network_map)
    end

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
end
# rubocop:enable Metrics/ClassLength

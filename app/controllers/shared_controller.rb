# frozen_string_literal: true

# Controller for managing shared impact cards
class SharedController < ApplicationController
  include ActiveTabItem

  skip_before_action :set_session_workspace_id
  skip_before_action :authenticate_user!
  skip_before_action :set_paper_trail_whodunnit

  before_action :set_scorecard

  def show # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/PerceivedComplexity
    tab_item :grid
    response.headers.delete('X-Frame-Options')

    @legend_items = fetch_legend_items(@scorecard)

    @date = params[:date]
    @parsed_date = @date.blank? ? nil : Date.parse(@date)

    @focus_areas = FocusArea.per_data_model(@scorecard.impact_card_data_model_id).order(
      'focus_area_groups.position', :position
    )

    @subsystem_tags = @scorecard.subsystem_tags.order('lower(trim(subsystem_tags.name))').uniq
    @statuses = ChecklistItem.statuses.keys.excluding('no_comment').map { |status| [status.humanize, status] }

    @selected_statuses = Array.wrap(params[:statuses])

    @selected_subsystem_tags =
      if params[:subsystem_tags].blank?
        SubsystemTag.none
      else
        SubsystemTag.where(workspace: @scorecard.workspace, name: params[:subsystem_tags].compact)
      end

    @scorecard_grid = ScorecardGrid.execute(@scorecard, @parsed_date)

    if @scorecard.present?
      if params[:iframe] == 'true'
        render('show_iframe', layout: false)
      else
        render(layout: 'embedded')
      end

    else
      render(file: 'public/404.html', layout: 'embedded', status: :not_found)
    end
  end

  def stakeholder_network # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    tab_item :network

    @graph = Insights::StakeholderNetwork.new(@scorecard)

    @stakeholder_types = @scorecard.stakeholder_types.order('lower(trim(name))')
    @legend_items = @stakeholder_types.map do |stakeholder_type|
      { label: stakeholder_type.name, color: stakeholder_type.color }
    end

    @show_labels = params[:show_labels].in?(%w[true 1])

    @selected_stakeholder_types =
      if params[:stakeholder_types].blank?
        StakeholderType.none
      else
        StakeholderType.where(workspace: @scorecard.workspace, name: params[:stakeholder_types].compact)
      end

    render(layout: 'embedded')
  end

  def thematic_map # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    tab_item :thematic_map

    @graph = Insights::TargetsNetwork.new(@scorecard)
    @stakeholder_types = @scorecard.stakeholder_types.order(:name).uniq

    @show_labels = params[:show_labels].in?(%w[true 1])
    @legend_items = fetch_legend_items(@scorecard)

    @stakeholders = @scorecard.organisations.order(Arel.sql('trim(organisations.name)')).uniq
    @selected_stakeholders =
      if params[:stakeholders].blank?
        Organisation.none
      else
        Organisation.where(workspace: @scorecard.workspace, name: params[:stakeholders].compact)
      end

    @initiatives = @scorecard.initiatives.order(:name).uniq
    @selected_initiatives =
      if params[:initiatives].blank?
        Initiative.none
      else
        @scorecard.initiatives.where(name: params[:initiatives].compact)
      end

    render(layout: 'embedded')
  end

  private

  # SMELL: Duplicated in app/controllers/impact_cards_controller.rb
  def fetch_legend_items(impact_card)
    FocusArea
      .per_data_model(impact_card.impact_card_data_model_id)
      .joins(:focus_area_group)
      .order('focus_area_groups.position, focus_areas.position')
      .map { |focus_area| { label: focus_area.name, color: focus_area.actual_color } }
  end

  def set_scorecard
    @scorecard = Scorecard.find_by(shared_link_id: params[:id])
  end
end

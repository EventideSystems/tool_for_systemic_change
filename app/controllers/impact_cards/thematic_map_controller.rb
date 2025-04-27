# frozen_string_literal: true

module ImpactCards
  # Controller for thematic map for each ImpactCard
  class ThematicMapController < ApplicationController
    include ActiveTabItem

    sidebar_item :impact_cards
    tab_item :thematic_map

    def index # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @scorecard = Scorecard.find(params[:impact_card_id])
      authorize(@scorecard, :show?)

      @legend_items = fetch_legend_items(@scorecard)
      @graph = Insights::TargetsNetwork.new(@scorecard)
      @stakeholder_types = @scorecard.stakeholder_types.order(:name).uniq

      @show_labels = params[:show_labels].in?(%w[true 1])

      @stakeholders = @scorecard.organisations.order(Arel.sql('trim(organisations.name)')).uniq
      @selected_stakeholders =
        if params[:stakeholders].blank?
          Organisation.none
        else
          Organisation.where(workspace: current_workspace, name: params[:stakeholders].compact)
        end

      @initiatives = @scorecard.initiatives.order(:name).uniq
      @selected_initiatives =
        if params[:initiatives].blank?
          Initiative.none
        else
          @scorecard.initiatives.where(name: params[:initiatives].compact)
        end
    end

    private

    # SMELL: Duplicate code, also found in impact_cards_controller.rb
    def fetch_legend_items(impact_card)
      FocusArea
        .per_data_model(impact_card.data_model_id)
        .joins(:focus_area_group)
        .order('focus_area_groups.position, focus_areas.position')
        .map { |focus_area| { label: focus_area.name, color: focus_area.color } }
    end
  end
end

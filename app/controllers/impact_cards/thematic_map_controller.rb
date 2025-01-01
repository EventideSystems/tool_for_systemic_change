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

      @graph = Insights::TargetsNetwork.new(@scorecard)
      @stakeholder_types = @scorecard.stakeholder_types.order(:name).uniq

      @show_labels = params[:show_labels].in?(%w[true 1])

      @stakeholders = @scorecard.organisations.order(Arel.sql('trim(organisations.name)')).uniq
      @selected_stakeholders =
        if params[:stakeholders].blank?
          Organisation.none
        else
          Organisation.where(account: current_account, name: params[:stakeholders].compact)
        end

      @initiatives = @scorecard.initiatives.order(:name).uniq
      @selected_initiatives =
        if params[:initiatives].blank?
          Initiative.none
        else
          @scorecard.initiatives.where(name: params[:initiatives].compact)
        end
    end
  end
end

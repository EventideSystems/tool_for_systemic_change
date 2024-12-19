# frozen_string_literal: true

module ImpactCards
  # Controller for thematic map for each ImpactCard
  class ThematicMapController < ApplicationController
    sidebar_item :impact_cards

    def index # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @scorecard = Scorecard.find(params[:impact_card_id])
      authorize(@scorecard, :show?)

      @graph = Insights::TargetsNetwork.new(@scorecard)

      @stakeholder_types = @scorecard.stakeholder_types.order(:name).uniq
      @show_labels = params[:show_labels].in?(%w[true 1])

      @selected_stakeholder_types =
        if params[:stakeholder_types].blank?
          StakeholderType.none
        else
          StakeholderType.where(account: current_account, name: params[:stakeholder_types].compact)
        end
    end
  end
end

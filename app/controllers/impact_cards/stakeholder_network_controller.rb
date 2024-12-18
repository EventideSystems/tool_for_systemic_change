# frozen_string_literal: true

module ImpactCards
  # Controller for Stakeholder network for each ImpactCard
  class StakeholderNetworkController < ApplicationController
    sidebar_item :impact_cards

    def index
      @scorecard = Scorecard.find(params[:impact_card_id])
      authorize(@scorecard, :show?)

      @graph = Insights::StakeholderNetwork.new(@scorecard)

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

# frozen_string_literal: true

module ImpactCards
  # Controller for Stakeholder network for each ImpactCard
  class StakeholderNetworkController < ApplicationController
    sidebar_item :impact_cards

    def index
      @scorecard = Scorecard.find(params[:impact_card_id])
      authorize(@scorecard, :show?)

      @graph = Insights::StakeholderNetwork.new(@scorecard)

      # @stakeholders_network = StakeholdersNetwork.new(@impact_card)
    end
  end
end

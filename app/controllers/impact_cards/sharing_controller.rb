# frozen_string_literal: true

module ImpactCards
  # Controller for ImpactCard details
  class SharingController < ApplicationController
    include ActiveTabItem

    sidebar_item :impact_cards
    tab_item :sharing

    def index
      @scorecard = Scorecard.find(params[:impact_card_id])
      authorize(@scorecard, :show?)
    end
  end
end

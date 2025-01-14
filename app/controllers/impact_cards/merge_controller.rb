# frozen_string_literal: true

module ImpactCards
  # Controller for handling merging of impact cards
  class MergeController < ApplicationController
    sidebar_item :impact_cards

    def new
      @source = Scorecard.find(params[:source_id])
      authorize(@source, :merge?)
    end

    def create
      @source = Scorecard.find(params[:source_id])
      @target = Scorecard.find(params[:target_id])

      authorize(@source, :merge?)
      authorize(@target, :merge?)

      MergeImpactCards.new(@source, @target).call

      redirect_to impact_card_path(@target), notice: 'Impact cards merged successfully'
    end
  end
end

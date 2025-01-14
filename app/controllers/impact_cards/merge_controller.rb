# frozen_string_literal: true

module ImpactCards
  # Controller for handling merging of impact cards
  class MergeController < ApplicationController
    sidebar_item :impact_cards

    def new
      @source = Scorecard.find(params[:impact_card_id])
      @targets = Scorecard.where(account_id: @source.account_id, type: @source.type).where.not(id: @source.id)
      authorize(@source, :merge?)
    end

    def create
      @source = Scorecard.find(params[:source_id])
      @target = Scorecard.find(params[:target_id])

      authorize(@source, :merge?)
      authorize(@target, :merge?)

      merge_cards!(params[:merge_type], @source, @target)

      redirect_to impact_card_path(@target), notice: 'Impact cards merged successfully'
    end

    private

    def merge_cards!(merge_type, source, target)
      case merge_type
      when 'deep'
        ImpactCards::DeepMerge.call(impact_card: target, other_impact_card: source)
      when 'shallow'
        target.merge(source)
      end
    end
  end
end

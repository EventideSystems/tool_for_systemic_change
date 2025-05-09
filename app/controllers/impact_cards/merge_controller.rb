# frozen_string_literal: true

module ImpactCards
  # Controller for handling merging of impact cards
  class MergeController < ApplicationController
    sidebar_item :impact_cards

    def new
      @target = Scorecard.find(params[:impact_card_id])
      @sources = Scorecard.where(
        workspace_id: @target.workspace_id,
        data_model_id: @target.data_model_id
      ).where.not(id: @target.id)

      authorize(@target, :merge?)
    end

    def create # rubocop:disable Metrics/AbcSize
      @target = Scorecard.find(params[:target_id])
      @source = Scorecard.find(params[:source_id])

      raise 'Cannot merge cards using different data models' if @source.data_model != @target.data_model
      raise 'Cannot merge cards from different workspaces' if @source.workspace_id != @target.workspace_id

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

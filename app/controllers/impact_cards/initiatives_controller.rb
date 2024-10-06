# frozen_string_literal: true

module ImpactCards
  class InitiativesController < ApplicationController
    def show
      @impact_card = Scorecard.find(params[:impact_card_id])
      authorize(@impact_card, :show?)

      @initiative = @impact_card.initiatives.find(params[:id])
      authorize(@initiative, :edit?)

      @focus_areas_groups = FocusAreaGroup
        .where(scorecard_type: @impact_card.type, account_id: @impact_card.account_id)
        .order(:position)

      @grouped_checklist_items = @initiative.checklist_items_ordered_by_ordered_focus_area
    end
  end
end

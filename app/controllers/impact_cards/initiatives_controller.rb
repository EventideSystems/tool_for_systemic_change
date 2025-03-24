# frozen_string_literal: true

module ImpactCards
  # Controller for Initiatives, nested under ImpactCards
  class InitiativesController < ::InitiativesController
    sidebar_item :impact_cards

    def show
      @impact_card = Scorecard.find(params[:impact_card_id])
      authorize(@impact_card, :show?)

      @initiative = @impact_card.initiatives.find(params[:id])
      authorize(@initiative, :edit_data?)

      @focus_areas_groups = FocusAreaGroup
                            .where(scorecard_type: @impact_card.type, workspace_id: @impact_card.workspace_id)
                            .order(:position)

      @grouped_checklist_items = @initiative.checklist_items_ordered_by_ordered_focus_area
    end
  end
end

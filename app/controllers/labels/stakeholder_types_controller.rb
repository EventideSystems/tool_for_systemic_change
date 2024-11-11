# frozen_string_literal: true

module Labels
  # Controller for managing Stakeholder Types as labels
  class StakeholderTypesController < LabelsController
    sidebar_item :stakeholder_types

    private

    def label_klass = StakeholderType
    def label_params = params.fetch(:stakeholder_type, {}).permit(:name, :description, :color)
  end
end

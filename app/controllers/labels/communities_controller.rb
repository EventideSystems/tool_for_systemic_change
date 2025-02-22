# frozen_string_literal: true

module Labels
  # Controller for managing Communities as labels
  class CommunitiesController < LabelsController
    sidebar_item :communities

    private

    def label_klass = Community
    def label_params = params.fetch(:community, {}).permit(:name, :description, :color)
    def label_index_path = communities_path
  end
end

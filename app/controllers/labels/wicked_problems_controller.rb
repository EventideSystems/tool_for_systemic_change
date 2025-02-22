# frozen_string_literal: true

module Labels
  # Controller for managing Wicked Problems as labels
  class WickedProblemsController < LabelsController
    sidebar_item :problems

    private

    def label_klass = WickedProblem
    def label_params = params.fetch(:wicked_problem, {}).permit(:name, :description, :color)
    def label_index_path = wicked_problems_path
  end
end

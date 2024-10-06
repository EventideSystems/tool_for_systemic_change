# frozen_string_literal: true

module Labels
  class WickedProblemsController < LabelsController
    sidebar_item :problems

    private

    def label_klass = WickedProblem
    def label_params = params.fetch(:wicked_problem, {}).permit(:name, :description, :color)
  end
end

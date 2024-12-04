# frozen_string_literal: true

module Labels
  # Controller for managing Subsystem Tags as labels
  class SubsystemTagsController < LabelsController
    sidebar_item :subsystem_tags

    private

    def label_klass = SubsystemTag
    def label_params = params.fetch(:subsystem_tag, {}).permit(:name, :description, :color)
  end
end

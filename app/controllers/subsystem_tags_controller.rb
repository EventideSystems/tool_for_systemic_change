class SubsystemTagsController < LabelsController

  sidebar_item :subsystem_tags

  private

  def label_klass
    SubsystemTag
  end

  def label_params
    params.fetch(:subsystem_tag, {}).permit(:name, :description, :color)
  end
end

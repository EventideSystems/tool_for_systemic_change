class CommunitiesController < LabelsController
  include VerifyPolicies

  sidebar_item :communities

  private

  def label_klass
    Community
  end

  def label_params
    params.fetch(:community, {}).permit(:name, :description, :color)
  end

end

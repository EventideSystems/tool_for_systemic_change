class WickedProblemsController < LabelsController
  include VerifyPolicies

  sidebar_item :problems

  # def show
  #   @wicked_problem.readonly!

  #   respond_to do |format|
  #     format.html { render :show }
  #     format.json { render json: @wicked_problem }
  #   end
  # end

  private

  def label_klass
    WickedProblem
  end

  def label_params
    params.fetch(:wicked_problem, {}).permit(:name, :description, :color)
  end
end

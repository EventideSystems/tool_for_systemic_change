class WickedProblemsController < ApplicationController
  include VerifyPolicies

  before_action :set_wicked_problem, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update]

  # add_breadcrumb "Wicked Problems / Opportunities", :wicked_problems_path

  sidebar_item :problems

  def index
    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(WickedProblem).order(:name).ransack(search_params[:q])
    wicked_problems = @q.result(distinct: true)

    @pagy, @wicked_problems = pagy(wicked_problems, limit: 10, link_extra: 'data-turbo-frame="wicked_problems"')

    respond_to do |format|
      format.html
      format.turbo_stream
      format.css
    end
  end

  def show
    @wicked_problem.readonly!
    # add_breadcrumb @wicked_problem.name

    respond_to do |format|
      format.html { render :show }
      format.json { render json: @wicked_problem }
    end
  end

  def new
    @wicked_problem = current_account.wicked_problems.build
    authorize @wicked_problem

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
     # add_breadcrumb @wicked_problem.name
  end

  def create
    @wicked_problem = current_account.wicked_problems.build(wicked_problem_params)
    authorize @wicked_problem

    respond_to do |format|
      if @wicked_problem.save
        @wicked_problems = policy_scope(WickedProblem).all
        format.turbo_stream
        format.html { redirect_to wicked_problems_path, notice: 'Wicked problem / opportunity was successfully created.' }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.update('new_wicked_problem_form', partial: 'wicked_problems/form', locals: { wicked_problem: @wicked_problem }) }
        format.html { render :new }
      end
    end
  end

  def update
    if @wicked_problem.update(wicked_problem_params)
      @wicked_problems = policy_scope(WickedProblem).all
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to wicked_problems_path, notice: 'Wicked problem / opportunity was successfully updated.' }
      end
    else
      render :edit
    end
  end

  def destroy
    @wicked_problem.delete

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@wicked_problem) }
      format.html { redirect_to wicked_problems_path, notice: 'Wicked problem / opportunity was successfully deleted.' }
    end
  end

  def content_title
    'Wicked Problems / Opportunities'
  end

  def content_subtitle
    @wicked_problem&.name.presence || super
  end

  private

  def set_wicked_problem
    @wicked_problem = current_account.wicked_problems.find(params[:id])
    authorize @wicked_problem
  end

  def wicked_problem_params
    params.fetch(:wicked_problem, {}).permit(:name, :description, :color)
  end
end

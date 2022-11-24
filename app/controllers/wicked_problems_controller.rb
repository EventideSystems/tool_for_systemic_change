class WickedProblemsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_wicked_problem, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update]

  add_breadcrumb "Wicked Problems / Opportunities", :wicked_problems_path

  def index
    @wicked_problems = policy_scope(WickedProblem).order(sort_order).page params[:page]
  end

  def show
    @wicked_problem.readonly!
    add_breadcrumb @wicked_problem.name
  end

  def new
    @wicked_problem = current_account.wicked_problems.build
    authorize @wicked_problem
    add_breadcrumb "New"
  end

  def edit
     add_breadcrumb @wicked_problem.name
  end

  def create
    @wicked_problem = current_account.wicked_problems.build(wicked_problem_params)
    authorize @wicked_problem

    respond_to do |format|
      if @wicked_problem.save
        format.html { redirect_to wicked_problems_path, notice: 'Wicked problem / opportunity was successfully created.' }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def update
    if @wicked_problem.update(wicked_problem_params)
      redirect_to wicked_problems_path, notice: 'Wicked problem / opportunity was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @wicked_problem.delete

    redirect_to wicked_problems_url, notice: 'Wicked problem / opportunity was successfully deleted.'
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
    params.fetch(:wicked_problem, {}).permit(:name, :description)
  end
end

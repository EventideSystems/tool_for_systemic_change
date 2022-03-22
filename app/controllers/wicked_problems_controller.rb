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
        format.json { render :show, status: :created, location: @wicked_problem }
        format.js
      else
        format.html { render :new }
        format.json { render json: @wicked_problem.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @wicked_problem.update(wicked_problem_params)
        format.html { redirect_to wicked_problems_path, notice: 'Wicked problem / opportunity was successfully updated.' }
        format.json { render :show, status: :ok, location: @wicked_problem }
      else
        format.html { render :edit }
        format.json { render json: @wicked_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @wicked_problem.delete

    respond_to do |format|
      format.html { redirect_to wicked_problems_url, notice: 'Wicked problem / opportunity was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def content_title
    'Wicked Problems / Opportunities'
  end

  def content_subtitle
    return @wicked_problem.name if @wicked_problem.present?
    super
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

class WickedProblemsController < ApplicationController
  before_action :authenticate_user!
  
  before_action :set_wicked_problem, only: [:show, :edit, :update, :destroy]

  def index
    @wicked_problems = policy_scope(WickedProblem)
  end

  def show
  end

  def new
    @wicked_problem = WickedProblem.new
    authorize @wicked_problem
  end

  def edit
  end

  def create
    @wicked_problem = WickedProblem.new(wicked_problem_params)
    authorize @wicked_problem
    
    respond_to do |format|
      if @wicked_problem.save
        format.html { redirect_to @wicked_problem, notice: 'Wicked problem was successfully created.' }
        format.json { render :show, status: :created, location: @wicked_problem }
      else
        format.html { render :new }
        format.json { render json: @wicked_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @wicked_problem.update(wicked_problem_params)
        format.html { redirect_to @wicked_problem, notice: 'Wicked problem was successfully updated.' }
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
      format.html { redirect_to wicked_problems_url, notice: 'Wicked problem was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_wicked_problem
      @wicked_problem = WickedProblem.find(params[:id])
      authorize @wicked_problem
    end

    def wicked_problem_params
      params.require(:wicked_problem).permit(:name, :description)
    end
end

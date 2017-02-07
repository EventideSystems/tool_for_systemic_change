class WickedProblemsController < ApplicationController
  before_action :set_wicked_problem, only: [:show, :edit, :update, :destroy]

  # GET /wicked_problems
  # GET /wicked_problems.json
  def index
    @wicked_problems = WickedProblem.all
  end

  # GET /wicked_problems/1
  # GET /wicked_problems/1.json
  def show
  end

  # GET /wicked_problems/new
  def new
    @wicked_problem = WickedProblem.new
  end

  # GET /wicked_problems/1/edit
  def edit
  end

  # POST /wicked_problems
  # POST /wicked_problems.json
  def create
    @wicked_problem = WickedProblem.new(wicked_problem_params)

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

  # PATCH/PUT /wicked_problems/1
  # PATCH/PUT /wicked_problems/1.json
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

  # DELETE /wicked_problems/1
  # DELETE /wicked_problems/1.json
  def destroy
    @wicked_problem.destroy
    respond_to do |format|
      format.html { redirect_to wicked_problems_url, notice: 'Wicked problem was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wicked_problem
      @wicked_problem = WickedProblem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wicked_problem_params
      params.fetch(:wicked_problem, {})
    end
end

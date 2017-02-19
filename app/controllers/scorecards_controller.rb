class ScorecardsController < ApplicationController
  before_action :set_scorecard, only: [:show, :edit, :update, :destroy]

  # GET /scorecards
  # GET /scorecards.json
  def index
    @scorecards = policy_scope(Scorecard)
  end

  # GET /scorecards/1
  # GET /scorecards/1.json
  def show
  end

  # GET /scorecards/new
  def new
    @scorecard = Scorecard.new
    authorize @scorecard
  end

  # GET /scorecards/1/edit
  def edit
  end

  # POST /scorecards
  # POST /scorecards.json
  def create
    @scorecard = Scorecard.new(scorecard_params)
    authorize @scorecard

    respond_to do |format|
      if @scorecard.save
        format.html { redirect_to @scorecard, notice: 'Scorecard was successfully created.' }
        format.json { render :show, status: :created, location: @scorecard }
      else
        format.html { render :new }
        format.json { render json: @scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scorecards/1
  # PATCH/PUT /scorecards/1.json
  def update
    respond_to do |format|
      if @scorecard.update(scorecard_params)
        format.html { redirect_to @scorecard, notice: 'Scorecard was successfully updated.' }
        format.json { render :show, status: :ok, location: @scorecard }
      else
        format.html { render :edit }
        format.json { render json: @scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scorecards/1
  # DELETE /scorecards/1.json
  def destroy
    @scorecard.destroy
    respond_to do |format|
      format.html { redirect_to scorecards_url, notice: 'Scorecard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scorecard
      @scorecard = Scorecard.find(params[:id])
      authorize @scorecard
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scorecard_params
      params.fetch(:scorecard, {})
    end
end

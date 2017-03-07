class ScorecardsController < ApplicationController
  before_action :set_scorecard, only: [:show, :edit, :update, :destroy]  
  before_action :require_account_selected, only: [:new, :create, :edit, :update] 

  def index
    @scorecards = policy_scope(Scorecard).page params[:page]
  end

  def show
  end

  def new
    @scorecard = current_account.scorecards.build
    authorize @scorecard
  end

  def edit
  end

  def create
    @scorecard = current_account.scorecards.build(scorecard_params)
    authorize @scorecard

    respond_to do |format|
      if @scorecard.save
        format.html { redirect_to scorecards_path, notice: 'Scorecard was successfully created.' }
        format.json { render :show, status: :created, location: @scorecard }
      else
        format.html { render :new }
        format.json { render json: @scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

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

  def destroy
    @scorecard.destroy
    respond_to do |format|
      format.html { redirect_to scorecards_url, notice: 'Scorecard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_scorecard
      @scorecard = current_account.scorecards.find(params[:id])
      authorize @scorecard
    end

    def scorecard_params
      params.require(:scorecard).permit(
        :name, 
        :description, 
        :wicked_problem_id,
        :community_id,
        initiatives_attributes: [
          :name,
          :description,
          :scorecard_id,
          :started_at,
          :finished_at,
          :dates_confirmed,
          :contact_name,
          :contact_email,
          :contact_phone,
          :contact_website,
          :contact_position,
          initiatives_organisations_attributes: [
            :organisation_id
          ]
        ]
      )
    end
end
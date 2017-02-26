class ScorecardsController < ApplicationController
  before_action :set_scorecard, only: [:show, :edit, :update, :destroy]  
  before_action :require_account_selected, only: [:new, :create, :edit, :update] 

  def index
    @scorecards = policy_scope(Scorecard)
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
    @scorecard.build_wicked_problem(wicked_problem_params) unless @scorecard.wicked_problem
    @scorecard.build_community(community_params) unless @scorecard.community
    
    if initiatives_params[:initiatives_attributes]
      initiatives_params[:initiatives_attributes].each do |index, initiative_params|
        organisations_attributes = initiative_params.delete(:organisations_attributes)
      
        initiative = @scorecard.initiatives.build(initiative_params)
      
        organisations_attributes.each do |index, organisation_params|
          organisation = if organisation_params[:id].present?
            current_account.organisations.find(organisation_params[:id])
          else
            current_account.organisations.build(organisation_params)
          end
        
          initiative.organisations << organisation
        end
      end
    end
    
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

    def default_params
      default_params_hash = current_account ? { account_id: current_account.id } : {}
      ActionController::Parameters.new(default_params_hash).permit!
    end
  
    def set_scorecard
      @scorecard = Scorecard.find(params[:id])
      authorize @scorecard
    end
    
    def wicked_problem_params
      selected_params = params.require(:scorecard).permit(:wicked_problem_name, :wicked_problem_description)
      {
        name: selected_params[:wicked_problem_name],
        description: selected_params[:wicked_problem_description],
        account_id: current_account.id
      }
    end
    
    def community_params
      selected_params = params.require(:scorecard).permit(:community_name, :community_description)
      {
        name: selected_params[:community_name],
        description: selected_params[:community_description],
        account_id: current_account.id
      }
    end
    
    def initiatives_params
      params.require(:scorecard).permit(
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
          organisations_attributes: [
            :id, 
            # :name,
            # :description
          ] 
        ]
      )
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def scorecard_params
      params.require(:scorecard).permit(
        :name, 
        :description, 
        :wicked_problem_id,
        :community_id
      )
    end
end



# "scorecard"=>{"account_id"=>"10", "name"=>"", "description"=>"", "wicked_problem_id"=>"", "wicked_problem_name"=>"", "wicked_problem_description"=>"", "community_id"=>"", "community_name"=>"", "community_description"=>"", "initiatives_attributes"=>{"0"=>{"name"=>"", "description"=>"", "organisations_attributes"=>{"0"=>{"name"=>"", "description"=>"YYY"}, "1"=>{"name"=>"", "description"=>"XXX"}}, "started_at(1i)"=>"2017", "started_at(2i)"=>"2", "started_at(3i)"=>"20", "finished_at(1i)"=>"2017", "finished_at(2i)"=>"2", "finished_at(3i)"=>"20", "contact_name"=>"", "contact_email"=>"", "contact_website"=>"", "contact_position"=>""}}}, "commit"=>"Create Scorecard"}
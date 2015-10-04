class ScorecardsController < AuthenticatedController
  before_action :set_scorecard, only: [:show, :edit, :update, :destroy]
  before_action :set_client, only: [:create, :update]

  resource_description do
    formats ['json']
  end

  api :GET, '/scorecards'
  def index
    @scorecards = Scorecard.for_user(current_user)

    render json: @scorecards, include: ['initiatives']
  end

  api :GET, '/scorecards/:id'
  param :id, :number, required: true
  def show
    render json: @scorecard, include: ['initiatives']
  end

  # POST /scorecards
  # POST /scorecards.json
  def create
    # TODO Need to check each relationship and determine if current user
    # has access

    data_attributes = normalize(params[:data])
    included_attributes = normalize_included(params[:included])

    if data_attributes[:client_id].nil?
      data_attributes[:client_id] = @client.id
    end
    # Need to collect errors as we go

    success = false
    ActiveRecord::Base.transaction do

      included_attributes.each do |included|
        if included.attributes[:client_id].nil?
          included.attributes[:client_id] = @client.id
        end

        case included.type
        when :community then
          community = Community.create!(permitted_community_params(included.attributes))
          data_attributes[:community_id] = community.id
        when :wicked_problem then
          wicked_problem = WickedProblem.create!(permitted_wicked_problem_params(included.attributes))
          data_attributes[:wicked_problem_id] = wicked_problem.id
        end
      end

      @scorecard = Scorecard.create!(permitted_scorecard_params(data_attributes))
      success = true

      # SMELL Similar code to above - also inefficient
      included_attributes.each do |included|
        if included.type == :initiative
          included.attributes.merge!(scorecard_id: @scorecard.id)
          Initiative.create!(permitted_initiative_params(included.attributes))
        else
          #
        end
      end
    end

    respond_to do |format|
      if success
        format.html { redirect_to @scorecard, notice: 'Scorecard was successfully created.' }
        format.json { render json: @scorecard, status: :created, location: @scorecard }
      else
        format.html { render :new }
        format.json { render json: @scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scorecards/1
  # PATCH/PUT /scorecards/1.json
  def update
    # TODO Need to check each relationship and determine if current user
    # has access

    attributes = permitted_scorecard_params(normalize(params[:data]))

    respond_to do |format|
      if @scorecard.update(attributes)
        format.html { redirect_to @scorecard, notice: 'Scorecard was successfully updated.' }
        format.json { render json: { status: :ok, location: @scorecard } }
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

    def set_client
      @client = current_user.client
    end

    def set_scorecard
      @scorecard = Scorecard.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    end

    def permitted_community_params(params)
      params.permit(:name, :description, :client_id)
    end

    def permitted_wicked_problem_params(params)
      params.permit(:name, :description, :client_id)
    end

    def permitted_initiative_params(params)
      params.permit(:name, :description, :scorecard_id, organisation_ids: [])
    end

    def permitted_scorecard_params(params)
      params.permit(:name, :description, :client_id, :community_id, :wicked_problem_id, :organisations_ids)
    end

    def scorecard_params
      params.require(:data).permit(
        attributes: [:name, :description],
        relationships: [
          community: [data: [:id]],
          client: [data: [:id]],
          wicked_problem: [data: [:id]]
        ]
      )
    end

    # TODO No longer in use - DELETE
    def client_id_from_params(params)
      params[:relationships][:client][:data][:id].to_i
    rescue
      nil
    end

    # TODO No longer in use - DELETE
    def community_id_from_params(params)
      params[:relationships][:community][:data][:id].to_i
    end
end

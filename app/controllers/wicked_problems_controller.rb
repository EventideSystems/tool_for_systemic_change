class WickedProblemsController < AuthenticatedController
  before_action :set_wicked_problem, only: [:show, :edit, :update, :destroy]
  before_action :set_client, only: [:create, :update]

  # GET /wicked_problems.json
  def index
    @wicked_problems = WickedProblem.for_user(current_user)

    render json: @wicked_problems, include: ['initiatives']
  end

  # GET /wicked_problems/1
  # GET /wicked_problems/1.json
  def show
    render json: @wicked_problem, include: ['initiatives']
  end

  # POST /wicked_problems
  # POST /wicked_problems.json
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
        if included.type == :community

          if included.attributes[:client_id].nil?
            included.attributes[:client_id] = @client.id
          end
          community = Community.create!(permitted_community_params(included.attributes))
          data_attributes[:community_id] = community.id
        end
      end

      @wicked_problem = WickedProblem.create!(permitted_wicked_problem_params(data_attributes))
      success = true

      # SMELL Similar code to above - also inefficient
      included_attributes.each do |included|
        if included.type == :initiative
          included.attributes.merge!(wicked_problem_id: @wicked_problem.id)
          Initiative.create!(permitted_initiative_params(included.attributes))
        else
          #
        end
      end
    end

    respond_to do |format|
      if success
        format.html { redirect_to @wicked_problem, notice: 'WickedProblem was successfully created.' }
        format.json { render json: @wicked_problem, status: :created, location: @wicked_problem }
      else
        format.html { render :new }
        format.json { render json: @wicked_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wicked_problems/1
  # PATCH/PUT /wicked_problems/1.json
  def update
    # TODO Need to check each relationship and determine if current user
    # has access

    attributes = permitted_wicked_problem_params(normalize(params[:data]))

    respond_to do |format|
      if @wicked_problem.update(attributes)
        format.html { redirect_to @wicked_problem, notice: 'WickedProblem was successfully updated.' }
        format.json { render json: { status: :ok, location: @wicked_problem } }
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
      format.html { redirect_to wicked_problems_url, notice: 'WickedProblem was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_client
      @client = current_user.client
    end

    def set_wicked_problem
      @wicked_problem = WickedProblem.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    end

    def permitted_community_params(params)
      params.permit(:name, :description, :client_id)
    end

    def permitted_initiative_params(params)
      params.permit(:name, :description, :wicked_problem_id, organisation_ids: [])
    end

    def permitted_wicked_problem_params(params)
      params.permit(:name, :description, :client_id, :community_id, :organisations_ids)
    end

    def wicked_problem_params
      params.require(:data).permit(
        attributes: [:name, :description],
        relationships: [
          community: [data: [:id]],
          client: [data: [:id]]
        ]
      )
    end

    def client_id_from_params(params)
      params[:relationships][:client][:data][:id].to_i
    rescue
      nil
    end

    def community_id_from_params(params)
      params[:relationships][:community][:data][:id].to_i
    end
end

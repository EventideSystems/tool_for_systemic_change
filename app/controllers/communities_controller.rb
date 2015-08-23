class CommunitiesController < AuthenticatedController
  before_action :set_community, only: [:show, :edit, :update, :destroy]

  # GET /communities
  # GET /communities.json
  def index
    @communities = Community.for_user(current_user)

    render json: @communities
  end

  # GET /communities/1
  # GET /communities/1.json
  def show
    render json: @community
  end

  # POST /communities
  # POST /communities.json
  def create
    administrating_organisation_id = administrating_organisation_id_from_params(community_params)
    administrating_organisation_id = current_user.administrating_organisation.id unless administrating_organisation_id

    attributes = community_params[:attributes].merge(
      administrating_organisation_id: administrating_organisation_id
    )
    @community = Community.new(attributes)

    respond_to do |format|
      if @community.save
        format.html { redirect_to @community, notice: 'Community was successfully created.' }
        format.json { render json: @community, status: :created, location: @community }
      else
        format.html { render :new }
        format.json { render json: @community.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /communities/1
  # PATCH/PUT /communities/1.json
  def update
    administrating_organisation_id = administrating_organisation_id_from_params(community_params)

    attributes = community_params[:attributes].merge(
      administrating_organisation_id: administrating_organisation_id
    )

    respond_to do |format|
      if @community.update(attributes)
        format.html { redirect_to @community, notice: 'Community was successfully updated.' }
        format.json { render json: { status: :ok, location: @community } }
      else
        format.html { render :edit }
        format.json { render json: @community.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /communities/1
  # DELETE /communities/1.json
  def destroy
    @community.destroy
    respond_to do |format|
      format.html { redirect_to communities_url, notice: 'Community was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_community
      @community = Community.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    end

    # SMELL Dupe of code in wicked_problems_controller. Refactor into concern
    def administrating_organisation_id_from_params(params)
      params[:relationships][:administrating_organisation][:data][:id].to_i
    rescue
      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def community_params
      params.require(:data).permit(
        attributes: [:name, :description],
        relationships: [
          # SMELL Not required, and we'd have to ensure it can take multiple
          # problems
          # wicked_problems: [data: [:id]],
          administrating_organisation: [data: [:id]]
        ]
      )
    end
end

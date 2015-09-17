class CommunitiesController < AuthenticatedController
  before_action :set_community, only: [:show, :edit, :update, :destroy]

  resource_description do
    formats ['json']

  end

  def_param_group :community do
    param :name, String, required: true
    param :description, String
  end

  api :GET, '/communities'
  def index
    @communities = Community.for_user(current_user)

    render json: @communities
  end

  api :GET, '/communities/:id'
  param :id, :number, required: true
  def show
    render json: @community
  end

  api :POST, '/communities'
  param_group :community
  def create
    client_id = client_id_from_params(community_params)
    client_id = current_user.client.id unless client_id

    attributes = community_params[:attributes].merge(
      client_id: client_id
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

  api :PUT, '/communities/:id'
  api :PATCH, '/communities/:id'
  param_group :community
  def update
    client_id = client_id_from_params(community_params)

    attributes = community_params[:attributes].merge(
      client_id: client_id
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

  api!
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
    def client_id_from_params(params)
      params[:relationships][:client][:data][:id].to_i
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
          client: [data: [:id]]
        ]
      )
    end
end

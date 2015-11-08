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
    @communities = Community.where(client_id: current_client.id)

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
    attributes = community_params[:attributes].merge(
      client_id: current_client.id
    )
    @community = Community.new(attributes)

    respond_to do |format|
      if @community.save
        format.json { render json: @community, status: :created, location: @community }
      else
        format.json { render json: @community.errors, status: :unprocessable_entity }
      end
    end
  end

  api :PUT, '/communities/:id'
  api :PATCH, '/communities/:id'
  param_group :community
  def update
    attributes = community_params[:attributes].merge(
      client_id: current_client.id
    )

    respond_to do |format|
      if @community.update(attributes)
        format.json { render json: { status: :ok, location: @community } }
      else
        format.json { render json: @community.errors, status: :unprocessable_entity }
      end
    end
  end

  api!
  def destroy
    @community.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

    def set_community
      @community = current_client.communities.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise User::NotAuthorized
    end

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

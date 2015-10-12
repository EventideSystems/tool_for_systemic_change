class ClientsController < AuthenticatedController
  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_staff_user!, except: [:index, :show]

  resource_description do
    formats ['json']
  end

  def_param_group :client do
    param :name, String, required: true
    param :description, String
  end

  api :GET, '/clients'
  def index
    @clients = Client.for_user(current_user)

    render json: @clients
  end

  api :GET, '/clients/:id'
  param :id, :number, required: true
  def show
    render json: @client
  end

  api :POST, '/clients'
  param_group :client
  def create
    attributes = normalize(client_params)
    @client = Client.new(attributes)

    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: 'client was successfully created.' }
        format.json { render json: @client, status: :created, location: @client }
      else
        format.html { render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  api :PUT, '/clients/:id'
  api :PATCH, '/clients/:id'
  param_group :client
  def update
    attributes = normalize(client_params)

    respond_to do |format|
      if @client.update(attributes)
        format.html { redirect_to @client, notice: 'Client was successfully updated.' }
        format.json { render json: { status: :ok, location: @client } }
      else
        format.html { render :edit }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  api :DELETE, '/clients/:id'
  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: 'Client was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def client_params
      params.require(:data).permit(attributes: [:name, :description])
    end

    def set_client
      @client = Client.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    end
end

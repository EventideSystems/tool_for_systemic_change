class CurrentClientController < AuthenticatedController
  before_action :authenticate_staff_user!, only: [:update]

  resource_description do
    formats ['json']
  end

  def show
    render json: current_client
  end

  def update
    @client = Client.find(params[:id])
    session[:staff_current_client_id] = @client.id if @client

    respond_to do |format|
      if @client
        format.json { render json: { status: :ok, location: current_client } }
      else
        format.json do
          render json: "Unknown client id: #{params[:id]}",
                 status: :unprocessable_entity
        end
      end
    end
  end
end

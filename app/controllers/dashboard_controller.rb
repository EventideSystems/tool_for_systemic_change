class DashboardController < AuthenticatedController

  def index

  end

  def show
    @dashboard = Dashboard.new(current_client)

    render json: @dashboard, serializer: DashboardSerializer
  end

end

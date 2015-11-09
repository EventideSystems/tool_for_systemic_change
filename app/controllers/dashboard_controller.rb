class DashboardController < AuthenticatedController

  def index

  end

  def show
    @dashboard = Dashboard.new(current_client)

    render json: @dashboard, include: ['activities'], serializer: DashboardSerializer
  end

end

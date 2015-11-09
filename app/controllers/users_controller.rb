class UsersController < AuthenticatedController

  resource_description do
    formats ['json']
  end

  api :GET, '/users'
  def index
    # TODO Remove redundancies
    query = current_user.user? ? User.where(id: current_user.id).includes(:client).all : User.where(client_id: current_client.id).includes(:client).all

    @users = finder_for_pagination(query).all

    render json: @users
  end

  api :GET, '/users/:id'
  param :id, :number, required: true
  def show
    @user = current_client.users.find(params[:id]) rescue (raise User::NotAuthorized )
    render json: @user
  end
end

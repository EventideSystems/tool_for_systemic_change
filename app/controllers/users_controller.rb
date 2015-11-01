class UsersController < AuthenticatedController

  resource_description do
    formats ['json']
  end

  api :GET, '/users'
  def index
    @users = current_user.user? ? User.where(id: current_user.id).all : current_client.users

    render json: @users
  end

  api :GET, '/users/:id'
  param :id, :number, required: true
  def show
    @user = current_client.users.find(params[:id]) rescue (raise User::NotAuthorized )
    render json: @user
  end
end

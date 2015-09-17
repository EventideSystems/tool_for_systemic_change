class UsersController < AuthenticatedController

  resource_description do
    formats ['json']
  end

  api :GET, '/users'
  def index
    @users = User.for_user(current_user)

    render json: @users
  end

  api :GET, '/users/:id'
  param :id, :number, required: true
  def show
    @user = User.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    render json: @user
  end
end

class UsersController < AuthenticatedController

  def index
    @users = User.for_user(current_user)

    render json: @users
  end

  def show
    @user = User.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    render json: @user
  end
end

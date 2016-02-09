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

  api :POST, '/users/:id/resend_invitation'
  param :id, :number, required: true
  def resend_invitation
    # NOTE Replace with Pundit check
    unless current_user.staff? || current_user.admin?
      raise User::NotAuthorized.new('Access denied')
    end

    @user = current_client.users.find(params[:id]) rescue (raise User::NotAuthorized )

    unless @user.status == 'invitation-pending'
      # NOTE Need a better error here
      raise User::NotAuthorized.new('Cannot resend invitations to an active user')
    end

    @user.invite!(current_user)

    render json: { status: :ok}
  end

  api :DELETE, '/users/:id'
  param :id, :number, required: true
  def destroy
    # NOTE Replace with Pundit check
    unless current_user.staff? || current_user.admin?
      raise User::NotAuthorized.new('Access denied')
    end

    @user = current_client.users.find(params[:id]) rescue (raise User::NotAuthorized )

    if @user == current_user
      raise User::NotAuthorized.new('Cannot delete own account')
    end

    @user.destroy

    render json: { status: :ok}
  end
end

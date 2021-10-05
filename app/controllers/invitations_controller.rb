class InvitationsController < Devise::InvitationsController

  layout 'application', only: [:new] # NOTE Defaults to 'devise' layout for other actions

  def update
    super
  end

  def create
    params[:user].delete(:system_role) unless policy(User).invite_with_system_role?
    account_role = params[:user].delete(:account_role)

    user = User.find_by_email(params[:user][:email])

    if user
      if current_account.users.include?(user)
        redirect_to users_path, alert: "A user with the email '#{user.email}' is already a member of this account."
      else
        AccountsUser.create!(user: user, account: current_account, account_role: account_role)
        redirect_to users_path, notice: 'User was successfully invited.'
      end
    elsif max_users_reached?
      redirect_to users_path, alert: "You have reached the maximum number of users for your account."
    else
      super do |resource|
        if resource.errors.empty?
          AccountsUser.create!(user: resource, account: current_account, account_role: account_role)
        end
      end
    end
  end

  def new
    self.resource = resource_class.new
    authorize self.resource
    render :new
  end

  private

  def max_users_reached?
    return false if current_account.max_users.zero? || current_account.max_users.blank?
    current_account.users.count >= current_account.max_users
  end


end

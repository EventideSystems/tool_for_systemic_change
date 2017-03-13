class InvitationsController < Devise::InvitationsController
  
  layout 'application', only: [:new] # NOTE Defaults to 'devise' layout for other actions
  
  def update
    super
  end
  
  def create
    params[:user].delete(:system_role) unless policy(User).invite_with_system_role?
    account_role = params[:user].delete(:account_role)
    super do |resource|
      if resource.errors.empty?
        AccountsUser.create!(user: resource, account: current_account, account_role: account_role)
      end
    end
  end
  
  def new
    self.resource = resource_class.new
    authorize self.resource 
    render :new
  end


end
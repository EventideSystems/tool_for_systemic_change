class InvitationsController < Devise::InvitationsController
  
  layout 'application'
  
  def update
    super
  end
  
  def create

    super
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [
      :email, 
      :name, 
      :system_role, 
      accounts_users_attributes: [
        :account_id,
        :account_role
      ]
    ])
  end
end
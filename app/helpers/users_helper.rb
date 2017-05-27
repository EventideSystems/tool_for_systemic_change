module UsersHelper
  
  def current_user_name
    return '' unless user_signed_in?
    return current_user.email unless current_user.name.present?
    current_user.name
  end
  
  def current_user_membership_summary
    return '' unless user_signed_in?
    "Member since #{current_user.created_at.strftime('%b. %Y')}"
  end
  
  def user_role_in_current_account(user)
    accounts_user = AccountsUser.where(user: user, account: current_account).first
    accounts_user.try(:account_role)
  end

end

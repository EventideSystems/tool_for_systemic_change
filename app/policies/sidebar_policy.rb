class SidebarPolicy < Struct.new(:user_context, :sidebar)
  
  def show_accounts_link?
    system_admin?
  end
  
  def show_subsystem_tags_link?
    system_admin?
  end
  
  def show_users_link?
    system_admin? || account_admin?(user_context.account, user_context.user)
  end
  
  # SMELL Similar code in application_policy
  def account_admin?(account, user)
    return false unless account
    AccountsUser.where(user: user, account: account).first.try(:admin?)
  end
  
  def system_admin?
    user_context.user.admin?
  end
end
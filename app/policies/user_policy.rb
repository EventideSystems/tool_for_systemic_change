class UserPolicy < ApplicationPolicy
  
  class Scope < Scope
    def resolve
      if account_admin?(user_context.account)|| system_admin?
        scope.joins(:accounts_users).where('accounts_users.account_id' => current_account.id)
      end
    end
  end
  
  class SystemScope < Scope 
    def resolve
      if user_context.user.admin?
        scope.with_deleted.all
      end
    end
  end
  
  def show?
    system_admin? || account_admin?(user_context.account) || account_member?(user_context.account)
  end
  
  def create?
    system_admin? || (account_admin?(user_context.account) && max_users_not_reached?(user_context.account))
  end
  
  def invite?
    create?
  end
  
  def invite_with_system_role?
    invite? && system_admin?
  end
  
  def update?
    system_admin? || account_admin?(user_context.account) || record == current_user 
  end

  def update_system_role?
    system_admin? && record != current_user
  end 
  
  def destroy?
    return false if user_context.user == record
    system_admin? || account_admin?(user_context.account)
  end
  
  def undelete?
    system_admin?
  end
  
  def resend_invitation?
    system_admin? || account_admin?(current_account)
  end
  
  def remove_from_account?
    return false if user_context.user == record
    system_admin? || account_admin?(user_context.account)
  end
    
  def max_users_not_reached?(account)
    return false unless account.present?
    return true if account.max_users == 0 # NOTE magic number, meaning no limit
    return account.users.count < account.max_users
  end

end

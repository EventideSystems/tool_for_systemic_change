class UserPolicy < ApplicationPolicy
  
  class Scope < Scope
    def resolve
      if user_context.user.admin?
        scope.all
      else
        # SMELL Should we be checking here to see if the user has access to this account? Probably
        scope.joins(:accounts_users).where('accounts_users.account_id' => current_account.id)
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
    system_admin? || account_admin?(user_context.account)
  end
  
  def destroy?
    return false if user_context.user == record
    system_admin? || account_admin?(user_context.account)
  end
  
  def max_users_not_reached?(account)
      return false unless account.present?
      return true if account.max_users == 0 # NOTE magic number, meaning no limit
      return account.users.count < account.max_users
    end

end
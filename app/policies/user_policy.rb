class UserPolicy < ApplicationPolicy
  
  class Scope < Scope
    def resolve
      if user_context.user.admin?
        scope.all
      else
        # SMELL Should we be checking here to see if the user has access to this account? Probably
        scope.where(account: user_context.account)
      end
    end
  end
  
  def show?
    system_admin? || account_admin?(user_context.account) || account_member?(user_context.account)
  end
  
  def create?
    system_admin? || account_admin?(user_context.account)
  end
  
  def update?
    system_admin? || account_admin?(user_context.account)
  end
  
  def destroy?
    return false if user_context.user == record
    system_admin? || account_admin?(user_context.account)
  end
  

end
class WickedProblemPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user_context.user.system_admin?
        scope.all
      else
        scope.where(account: user_context.account)
      end
    end
  end
  
  def show?
    user_context.user.admin?  
  end
  
  def new?
    user_context.user.admin?  
  end
  
  def create?
    user_context.user.admin?  
  end
  
  def edit?
    user_context.user.admin?  
  end
  
  def update?
    user_context.user.admin?  
  end
  
  def destroy?
    user_context.user.admin?  
  end
end

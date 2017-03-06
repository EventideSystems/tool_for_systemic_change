class AccountPolicy < ApplicationPolicy
  
  class Scope < Scope
    def resolve
      if system_admin?
        scope.all
      else
        scope.where(id: AccountsUser.where(user: current_user).pluck(:account_id))
      end
    end
  end

  def show?
    system_admin? || account_any_role?(record)
  end
  
  def create?
    system_admin?
  end
  
  def update?
    system_admin? || account_admin?(record)
  end
  
  def destroy?
    system_admin?
  end
  
  def switch?
    system_admin? || account_admin?(record)
  end
  


end
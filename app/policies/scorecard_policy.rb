class ScorecardPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      resolve_to_current_account
    end
  end
  
  def show?
    system_admin? || account_any_role?(record)
  end
  
  def create?
    system_admin? || account_admin?(record)
  end
  
  def update?
    system_admin? || account_admin?(record)
  end
  
  def destroy?
    system_admin? || account_admin?(record)
  end
  
end

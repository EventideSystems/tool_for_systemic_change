class InitiativePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if system_admin?
        scope.all
      else
        scope.joins(:scorecard).where(:'scorecards.account_id' => current_account.id)
      end
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

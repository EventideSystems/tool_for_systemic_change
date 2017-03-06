class ChecklistItemPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(initiative: :scorecard).where(:'scorecards.account_id' => current_account.id)
    end
  end
  
  def show?
    system_admin? || account_any_role?(record.account)
  end
  
  def create?
    system_admin? || account_admin?(record.account)
  end

  def update?
    system_admin? || account_any_role?(record.account)
  end
  
  def destroy?
    system_admin? || account_admin?(record.account)
  end
end

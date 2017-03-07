class ScorecardPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      resolve_to_current_account
    end
  end
  
  def show?
    system_admin? || account_any_role?(record.account)
  end
  
  def create?
    system_admin? || (account_admin?(record.account) && max_scorecards_not_reached?(record.account))
  end
  
  def update?
    system_admin? || account_admin?(record.account)
  end
  
  def destroy?
    system_admin? || account_admin?(record.account)
  end
  
  def max_scorecards_not_reached?(account)
    return false unless account.present?
    return true if account.max_scorecards == 0 # NOTE magic number, meaning no limit
    return account.scorecards.count < account.max_scorecards
  end
  
end

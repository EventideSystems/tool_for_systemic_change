# frozen_string_literal: true

class InitiativePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if current_account
        scope.joins(:scorecard).where('scorecards.account_id': current_account.id)
      else
        scope.joins(:scorecard).none
      end
    end
  end

  def show?
    system_admin? || account_any_role?(current_account)
  end

  def create?
    system_admin? || account_admin?(current_account)
  end

  def update?
    system_admin? || account_admin?(current_account)
  end

  def destroy?
    system_admin? || account_admin?(current_account)
  end
end

# frozen_string_literal: true

class InitiativePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case
      when current_account && (system_admin? || account_admin?(current_account))
        scope.joins(:scorecard).where('scorecards.account_id': current_account.id)
      when current_account && account_member?(current_account)
        scope.joins(:scorecard).not_archived.where('scorecards.account_id': current_account.id)
      else
        scope.joins(:scorecard).none
      end
    end
  end

  def show?
    system_admin? || (account_any_role?(current_account) && in_scope?(record))
  end

  def show_archived?
    system_admin? || account_admin?(current_account)
  end

  def create?
    system_admin? || account_admin?(current_account)
  end

  def update?
    system_admin? || (account_admin?(current_account) && in_scope?(record))
  end

  def destroy?
    system_admin? || (account_admin?(current_account) && in_scope?(record))
  end

  def archive?
    system_admin? || (account_admin?(current_account) && in_scope?(record))
  end

  private

  def in_scope?(record)
    Pundit.policy_scope(user_context, Initiative).exists?(id: record.id)
  end
end

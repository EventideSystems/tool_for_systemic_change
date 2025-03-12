# frozen_string_literal: true

class InitiativePolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve # rubocop:disable Metrics/AbcSize
      if current_account && (system_admin? || account_admin?(current_account))
        scope.joins(:scorecard).where('scorecards.account_id': current_account.id)
      elsif current_account && account_member?(current_account)
        scope.joins(:scorecard).not_archived.where('scorecards.account_id': current_account.id)
      else
        scope.joins(:scorecard).none
      end
    end
  end

  def show?
    system_admin? || (current_account_any_role? && record_in_scope?)
  end

  def show_archived?
    system_admin? || current_account_admin?
  end

  def create?
    system_admin? || (current_account_admin? && current_account_not_expired?)
  end

  def update?
    system_admin? || (current_account_admin? && record_in_scope? && current_account_not_expired?)
  end

  def destroy?
    system_admin? || (current_account_admin? && record_in_scope?)
  end

  def archive?
    system_admin? || (current_account_admin? && record_in_scope?)
  end

  alias edit_data? show?
end

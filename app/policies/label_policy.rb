# frozen_string_literal: true

# Common policy for Label records (e.g. StakeholderType, WickedProblem, SubsystemTag, etc)
class LabelPolicy < ApplicationPolicy
  # Scope class for LabelPolicy
  class Scope < Scope
    def resolve = resolve_to_current_account
  end

  def index? = true

  def show?
    system_admin? || record_in_scope?
  end

  def create?
    system_admin? || (account_admin?(current_account) && current_account_not_expired?)
  end

  def update?
    system_admin? || (account_admin?(current_account) && record_in_scope? && current_account_not_expired?)
  end

  def destroy?
    system_admin? || (account_admin?(current_account) && record_in_scope? && current_account_not_expired?)
  end
end

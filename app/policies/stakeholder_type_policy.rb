class StakeholderTypePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(account: current_account)
    end
  end

  def index?
    true
  end

  def show?
    system_admin? || record_in_scope?(record)
  end

  def create?
    system_admin? || account_admin?(current_account)
  end

  def update?
    system_admin? || (record_in_scope?(record) && account_admin?(current_account))
  end

  def destroy?
    record.organisations.empty? &&
    (
      system_admin? || (record_in_scope?(record) && account_admin?(current_account))
    )
  end

  private

  def record_in_scope?(record)
    Pundit.policy_scope(user_context, StakeholderType).exists?(id: record.id)
  end
end

# frozen_string_literal: true

class WickedProblemPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      resolve_to_current_account
    end
  end

  def index?
    current_account.present?
  end

  def show?
    system_admin? || account_any_role?(record.account)
  end

  def create?
    system_admin? || account_admin?(record.account)
  end

  def update?
    system_admin? || account_admin?(record.account)
  end

  def destroy?
    system_admin? || account_admin?(record.account)
  end
end

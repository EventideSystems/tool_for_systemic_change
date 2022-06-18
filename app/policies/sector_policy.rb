# frozen_string_literal: true

class SectorPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    system_admin? || account_any_role?(current_account)
  end

  def show?
    system_admin? || account_any_role?(current_account)
  end

  def create?
    system_admin?
  end

  def update?
    system_admin?
  end

  def destroy?
    system_admin?
  end
end

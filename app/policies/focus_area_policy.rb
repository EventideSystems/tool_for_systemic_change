# frozen_string_literal: true

class FocusAreaPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end

  def index?
    system_admin?
  end

  def show?
    system_admin?
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

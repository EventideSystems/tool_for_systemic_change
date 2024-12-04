# frozen_string_literal: true

class VideoTutorialPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope.all
    end
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

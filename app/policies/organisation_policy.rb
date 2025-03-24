# frozen_string_literal: true

class OrganisationPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      resolve_to_current_workspace
    end
  end

  def show?
    system_admin? || workspace_admin?(record.workspace) || workspace_member?(record.workspace)
  end

  def create?
    system_admin? || (current_workspace_admin? && current_workspace_not_expired?)
  end

  def update?
    system_admin? || (workspace_admin?(record.workspace) && current_workspace_not_expired?)
  end

  def destroy?
    system_admin? || workspace_admin?(record.workspace)
  end
end

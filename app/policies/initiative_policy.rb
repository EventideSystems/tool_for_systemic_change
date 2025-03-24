# frozen_string_literal: true

class InitiativePolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve # rubocop:disable Metrics/AbcSize
      if current_workspace && (system_admin? || workspace_admin?(current_workspace))
        scope.joins(:scorecard).where('scorecards.workspace_id': current_workspace.id)
      elsif current_workspace && workspace_member?(current_workspace)
        scope.joins(:scorecard).not_archived.where('scorecards.workspace_id': current_workspace.id)
      else
        scope.joins(:scorecard).none
      end
    end
  end

  def show?
    system_admin? || (current_workspace_any_role? && record_in_scope?)
  end

  def show_archived?
    system_admin? || current_workspace_admin?
  end

  def create?
    system_admin? || (current_workspace_admin? && current_workspace_not_expired?)
  end

  def update?
    system_admin? || (current_workspace_admin? && record_in_scope? && current_workspace_not_expired?)
  end

  def destroy?
    system_admin? || (current_workspace_admin? && record_in_scope?)
  end

  def archive?
    system_admin? || (current_workspace_admin? && record_in_scope?)
  end

  alias edit_data? show?
end

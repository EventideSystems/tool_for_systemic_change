# frozen_string_literal: true

class ScorecardPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      resolve_to_current_workspace
    end
  end

  def index?
    system_admin? || current_workspace_any_role?
  end

  def show?
    system_admin? || workspace_any_role?(record.workspace)
  end

  def create?
    system_admin? || (current_workspace_admin? && max_scorecards_not_reached? && current_workspace_not_expired?)
  end

  def update?
    system_admin? || (current_workspace_admin? && current_workspace_not_expired?)
  end

  def destroy?
    system_admin? || current_workspace_admin?
  end

  def show_shared_link?
    system_admin? || workspace_any_role?(record.workspace)
  end

  def copy?
    create?
  end

  def copy_options?
    copy?
  end

  def merge?
    system_admin? || (current_workspace_admin? && current_workspace_not_expired?)
  end

  def merge_options?
    merge?
  end

  def activity?
    system_admin? || workspace_any_role?(record.workspace)
  end

  def changes?
    system_admin? || workspace_any_role?(record.workspace)
  end

  def activities?
    system_admin? || workspace_any_role?(record.workspace)
  end

  def max_scorecards_not_reached?
    return false if current_workspace.blank?
    return true if current_workspace.max_scorecards.zero? # NOTE: magic number, meaning no limit

    current_workspace.scorecards.count < current_workspace.max_scorecards
  end

  alias add_initiative? edit?
end

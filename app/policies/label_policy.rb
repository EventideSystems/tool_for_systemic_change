# frozen_string_literal: true

# Common policy for Label records (e.g. StakeholderType, WickedProblem, SubsystemTag, etc)
class LabelPolicy < ApplicationPolicy
  # Scope class for LabelPolicy
  class Scope < Scope
    def resolve = resolve_to_current_workspace
  end

  def index? = true

  def show?
    system_admin? || record_in_scope?
  end

  def create?
    system_admin? || (workspace_admin?(current_workspace) && current_workspace_not_expired?)
  end

  def update?
    system_admin? || (workspace_admin?(current_workspace) && record_in_scope? && current_workspace_not_expired?)
  end

  def destroy?
    system_admin? || (workspace_admin?(current_workspace) && record_in_scope? && current_workspace_not_expired?)
  end
end

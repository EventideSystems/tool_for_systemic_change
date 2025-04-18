# frozen_string_literal: true

# Policy for impact card model records
class ImpactCardDataModelPolicy < ApplicationPolicy
  # Scope class for LabelPolicy
  class Scope < Scope
    def resolve
      scope.where(workspace_id: workspace_ids).or(ImpactCardDataModel.where(system_model: true))
    end

    def workspace_ids
      current_user.workspace_ids.to_a.then do |workspace_ids|
        workspace_ids.push(current_workspace.id) if system_admin?
        workspace_ids.uniq
      end
    end
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

  def copy_to_current_workspace?
    system_admin? || (
      workspace_admin?(current_workspace) &&
      (workspace_admin?(record.workspace) || record.system_model) &&
      current_workspace_not_expired?
    )
  end
end

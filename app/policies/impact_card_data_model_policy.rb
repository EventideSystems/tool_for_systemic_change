# frozen_string_literal: true

# Policy for impact card model records
class ImpactCardDataModelPolicy < ApplicationPolicy
  # Scope class for LabelPolicy
  class Scope < Scope
    def resolve
      scope.where(workspace_id: current_user.workspace_ids).or(ImpactCardDataModel.where(system_model: true))
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
end

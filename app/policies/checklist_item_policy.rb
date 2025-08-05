# frozen_string_literal: true

class ChecklistItemPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope.joins(initiative: :scorecard).where('scorecards.workspace_id': current_workspace.id)
    end
  end

  def show?
    system_admin? || workspace_any_role?(checklist_item_workspace)
  end

  def create?
    system_admin? || workspace_admin?(current_workspace)
  end

  def create_comment?
    update?
  end

  def update?
    system_admin? || (workspace_any_role?(checklist_item_workspace) && current_workspace_not_expired?)
  end

  # def update_comment?
  #   update?
  # end

  def destroy?
    system_admin? || workspace_admin?(checklist_item_workspace)
  end

  def import?
    system_admin? || workspace_admin?(current_workspace)
  end

  private

  def checklist_item_workspace
    record.initiative.scorecard.workspace
  end
end

# frozen_string_literal: true

module ScorecardComments
  class ImportPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
    class Scope < Scope # rubocop:disable Style/Documentation
      def resolve
        if current_workspace
          scope.joins(:scorecard).where('scorecards.workspace_id': current_workspace.id)
        else
          scope.joins(:scorecard).none
        end
      end
    end

    def show?
      system_admin? || workspace_any_role?(current_workspace)
    end

    def create?
      system_admin? || workspace_admin?(current_workspace)
    end

    def update?
      system_admin? || workspace_admin?(current_workspace)
    end

    def destroy?
      system_admin? || workspace_admin?(current_workspace)
    end
  end
end

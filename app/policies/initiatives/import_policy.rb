# frozen_string_literal: true

module Initiatives
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
      system_admin? || current_workspace_any_role?
    end

    def create?
      system_admin? || current_workspace_admin?
    end

    def update?
      system_admin? || current_workspace_admin?
    end

    def destroy?
      system_admin? || current_workspace_admin?
    end
  end
end

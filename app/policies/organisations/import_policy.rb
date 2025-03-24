# frozen_string_literal: true

module Organisations
  class ImportPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
    class Scope < Scope # rubocop:disable Style/Documentation
      def resolve
        resolve_to_current_workspace
      end
    end

    def show?
      system_admin? || workspace_admin?(record.workspace) || workspace_member?(record.workspace)
    end

    def create?
      system_admin? || workspace_admin?(record.workspace)
    end

    def update?
      system_admin? || workspace_admin?(record.workspace)
    end

    def destroy?
      system_admin? || workspace_admin?(record.workspace)
    end
  end
end

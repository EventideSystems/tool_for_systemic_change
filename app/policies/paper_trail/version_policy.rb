# frozen_string_literal: true

module PaperTrail
  class VersionPolicy < ApplicationPolicy
    class Scope < Scope # rubocop:disable Style/Documentation
      def resolve
        if system_admin? || workspace_admin?(current_workspace)
          visible_items_query(scope.where(workspace_id: current_workspace.id))
        else
          visible_items_query(
            scope.where(workspace_id: current_workspace.id, whodunnit: current_user.id)
          )
        end
      end

      private

      def visible_items_query(query)
        query
          .where.not(item_type: 'InitiativesOrganisation')
          .where.not(item_type: 'ChecklistItem', event: 'create')
      end
    end
  end
end

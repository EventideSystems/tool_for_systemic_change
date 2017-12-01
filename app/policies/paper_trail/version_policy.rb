class PaperTrail::VersionPolicy < ApplicationPolicy
  class Scope < Scope
    
    def resolve
      if system_admin? || account_admin?(current_account)
        visible_items_query(scope.where(account_id: current_account.id))
      else
        visible_items_query(
          scope.where(account_id: current_account.id, whodunnit: current_user.id)
        )
      end
    end
    
    private
    
    def visible_items_query(query)
      query.
        where.not(item_type: 'InitiativesOrganisation').
        where.not(item_type: 'ChecklistItem', event: 'create')
    end
  end
end

class PublicActivity::ActivityPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if system_admin? || account_admin?(current_account)
        scope.where(account_id: current_account.id)
      else
        scope.where(account_id: current_account.id, owner_id: current_user.id)
      end
    end
  end
end

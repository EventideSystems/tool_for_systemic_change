class PublicActivity::ActivityPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(account_id: current_account.id)
    end
  end

end

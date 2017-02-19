class PublicActivity::ActivityPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      resolve_to_current_account
    end
  end

end

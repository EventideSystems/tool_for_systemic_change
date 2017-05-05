class VideoTutorialPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
  def show?
    system_admin? || account_any_role?(current_account)
  end
  
  def create?
    system_admin?
  end
  
  def update?
    system_admin? 
  end
  
  def destroy?
    system_admin?
  end
end

class CharacteristicPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  
  def index?
    system_admin?
  end
  
  def show?
    system_admin?
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

  def description?
    true
  end
end

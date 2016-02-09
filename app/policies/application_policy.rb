class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def rails_admin?(action)
    case action
      when :dashboard
        user.staff?
      when :index
        user.staff?
      when :show
        user.staff?
      when :new
        user.staff?
      when :edit
        user.staff?
      when :destroy
        user.staff?
      when :export
        user.staff?
      when :history
        user.staff?
      when :show_in_app
        user.staff?
      when :invite_user
        user.staff?
      else
        raise ::Pundit::NotDefinedError, "unable to find policy #{action} for #{record}."
    end
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end

class ApplicationPolicy
  
  class Scope
    attr_reader :user_context, :scope
    
    delegate :user, :account, to: :user_context, prefix: :current

    def initialize(user_context, scope)
      @user_context = user_context
      @scope = scope
    end

    def resolve
      scope
    end
    
    def resolve_to_current_account
      scope.where(account: current_account)
    end  
    
    # SMELL Move all these to a concern
    def system_admin?
      user_context.user.admin?
    end
    
    def account_admin?(account)
      return false unless account
      AccountsUser.where(user: current_user, account: account).first.try(:admin?)
    end
  
    def account_member?(account)
      return false unless account
      AccountsUser.where(user: current_user, account: account).first.try(:member?)
    end
  end
  
  attr_reader :user_context, :record
  
  delegate :user, :account, to: :user_context, prefix: :current

  def initialize(user_context, record)
    @user_context = user_context
    @record       = record
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
    Pundit.policy_scope!(user_context, record.class)
  end
  
  def system_admin?
    current_user.admin?
  end

  def current_account
    user_context.account
  end
    
  def current_user
    user_context.user
  end
    
  def current_account_admin?
    current_user.admin? || account_admin?(user_context.account)
  end
  
  def account_admin?(account)
    return false unless account
    AccountsUser.where(user: current_user, account: account).first.try(:admin?)
  end
  
  def account_member?(account)
    return false unless account
    AccountsUser.where(user: current_user, account: account).first.try(:member?)
  end

  def account_any_role?(account)
    account_admin?(account) || account_member?(account)
  end
end

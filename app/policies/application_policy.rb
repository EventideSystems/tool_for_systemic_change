# frozen_string_literal: true

class ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope # rubocop:disable Style/Documentation
    attr_reader :user_context, :scope

    delegate :user, :workspace, to: :user_context, prefix: :current

    def initialize(user_context, scope)
      @user_context = user_context
      @scope = scope
    end

    def resolve
      scope
    end

    def resolve_to_current_workspace
      current_workspace.present? ? scope.where(workspace: current_workspace) : scope.none
    end

    # SMELL Move all these to a concern
    def system_admin?
      user_context.user.admin?
    end

    def workspace_admin?(workspace)
      return false unless workspace

      WorkspacesUser.where(user: current_user, workspace: workspace).first.try(:admin?)
    end

    def workspace_member?(workspace)
      return false unless workspace

      WorkspacesUser.where(user: current_user, workspace: workspace).first.try(:member?)
    end
  end

  attr_reader :user_context, :record

  delegate :user, :workspace, to: :user_context, prefix: :current

  def initialize(user_context, record)
    @user_context = user_context
    @record       = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
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

  def current_workspace
    user_context.workspace
  end

  def current_workspace_not_expired?
    !current_workspace.expired?
  end

  def current_user
    user_context.user
  end

  def current_workspace_admin?
    current_user.admin? || workspace_admin?(user_context.workspace)
  end

  def current_workspace_member?
    workspace_member?(user_context.workspace)
  end

  def current_workspace_any_role?
    current_workspace_admin? || current_workspace_member?
  end

  def workspace_admin?(workspace)
    return false unless workspace

    WorkspacesUser.where(user: current_user, workspace: workspace).first.try(:admin?)
  end

  def workspace_member?(workspace)
    return false unless workspace

    WorkspacesUser.where(user: current_user, workspace: workspace).first.try(:member?)
  end

  def workspace_any_role?(workspace)
    workspace_admin?(workspace) || workspace_member?(workspace)
  end

  private

  def record_in_scope? = scope.exists?(id: record.id)
end

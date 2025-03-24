# frozen_string_literal: true

# Helper methods for presenting workspaces - soon to be deprecated and replaced with 'workspaces'
module WorkspacesHelper
  def lookup_workspaces
    policy_scope(Workspace).all
  end

  def lookup_workspace_roles
    WorkspacesUser.workspace_roles.keys
  end

  def lookup_system_roles
    User.system_roles.keys
  end

  def max_users(workspace)
    "Max users: #{workspace.max_users.zero? ? 'unlimited' : workspace.max_users}"
  end

  def max_impact_cards(workspace)
    "Max impact cards: #{workspace.max_users.zero? ? 'unlimited' : workspace.max_scorecards}"
  end

  def expires_on(workspace)
    return 'Never expires' if workspace.expires_on.blank?

    "Expires on: #{workspace.expires_on}"
  end
end

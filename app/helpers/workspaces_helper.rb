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
    "Max users: #{limit_text(workspace.max_users)}"
  end

  def max_impact_cards(workspace)
    "Max impact cards: #{limit_text(workspace.max_users)}"
  end

  def expires_on(workspace)
    return 'Never expires' if workspace.expires_on.blank?

    "Expires on: #{workspace.expires_on}"
  end

  # NOTES: Magic number 0 is used to represent 'unlimited' in the database.
  def limit_text(value)
    value.zero? ? 'unlimited' : value
  end
end

class RenameWorkspaceUsersTableToWorkspacesUsers < ActiveRecord::Migration[8.0]
  def change
    rename_table :workspace_users, :workspaces_users
  end
end

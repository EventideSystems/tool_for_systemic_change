class RenameWorkspaceUsersAccountRoleToWorkspaceRole < ActiveRecord::Migration[8.0]
  def change
    rename_column :workspace_users, :account_role, :workspace_role
  end
end

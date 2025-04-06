class DeprecateFocusAreaGroupsWorkspaceId < ActiveRecord::Migration[8.0]
  def change
    rename_column :focus_area_groups, :workspace_id, :deprecated_workspace_id
  end
end

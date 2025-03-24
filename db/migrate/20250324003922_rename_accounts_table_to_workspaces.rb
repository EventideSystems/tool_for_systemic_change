# frozen_string_literal: true

# Refactor the database to rename the accounts table to workspaces
# and the account_users table to workspace_users
# See https://github.com/EventideSystems/tool_for_systemic_change/issues/1183
class RenameAccountsTableToWorkspaces < ActiveRecord::Migration[8.0]
  def change # rubocop:disable Metrics/MethodLength
    %i[
      accounts_users
      activities
      communities
      focus_area_groups
      imports
      organisations
      scorecards
      stakeholder_types
      subsystem_tags
      versions
      wicked_problems
    ].each do |table|
      rename_column table, :account_id, :workspace_id
    end

    rename_table :accounts, :workspaces
    rename_table :accounts_users, :workspace_users
  end
end

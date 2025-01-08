# frozen_string_literal: true

class SetClassicGridModeForExistingAccounts < ActiveRecord::Migration[8.0]
  def up
    Account.update_all(classic_grid_mode: true)
  end

  def down
    Account.update_all(classic_grid_mode: false)
  end
end

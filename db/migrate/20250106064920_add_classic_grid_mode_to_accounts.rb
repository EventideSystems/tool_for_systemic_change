class AddClassicGridModeToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :classic_grid_mode, :boolean, default: false
  end
end

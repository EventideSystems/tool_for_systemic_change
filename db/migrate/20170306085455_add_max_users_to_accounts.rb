class AddMaxUsersToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :max_users, :integer, default: 1
  end
end

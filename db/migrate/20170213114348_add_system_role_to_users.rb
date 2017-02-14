class AddSystemRoleToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :system_role, :string, default: 'regular' # Regular user
    add_index :users, :system_role
  end
end

class AddRoleAndAdminOrgToUsers < ActiveRecord::Migration
  def change
    add_column :users, :administrating_organisation_id, :integer
    add_column :users, :role, :integer, default: 0
  end
end

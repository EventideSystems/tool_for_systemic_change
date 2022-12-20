class AddAccountIdToSectors < ActiveRecord::Migration[7.0]
  def change
    add_column :sectors, :account_id, :integer, null: true
    add_index :sectors, :account_id
  end
end

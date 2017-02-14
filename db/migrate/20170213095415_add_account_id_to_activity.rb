class AddAccountIdToActivity < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :account_id, :integer
    add_index :activities, :account_id
  end
end

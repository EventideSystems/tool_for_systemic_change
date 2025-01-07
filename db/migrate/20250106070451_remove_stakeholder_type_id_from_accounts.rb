class RemoveStakeholderTypeIdFromAccounts < ActiveRecord::Migration[8.0]
  def change
    remove_column :accounts, :stakeholder_type_id, :integer
  end
end

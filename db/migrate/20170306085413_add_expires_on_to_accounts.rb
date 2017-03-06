class AddExpiresOnToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :expires_on, :date
  end
end

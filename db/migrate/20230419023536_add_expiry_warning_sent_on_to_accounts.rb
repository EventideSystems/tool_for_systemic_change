class AddExpiryWarningSentOnToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :expiry_warning_sent_on, :date, null: true
  end
end

class CreateAccountsUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts_users do |t|
      t.references :user
      t.references :account
      t.string :account_role
      t.timestamps
    end

    add_index :accounts_users, [:account_id, :user_id], unique: true
  end
end

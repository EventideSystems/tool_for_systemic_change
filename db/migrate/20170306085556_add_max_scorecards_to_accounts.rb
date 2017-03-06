class AddMaxScorecardsToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :max_scorecards, :integer, default: 1
  end
end

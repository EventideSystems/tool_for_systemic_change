class CreateScorecards < ActiveRecord::Migration[5.0]
  def change
    create_table :scorecards do |t|
      t.string   :name
      t.string   :description
      t.integer  :community_id
      t.integer  :account_id
      t.integer  :wicked_problem_id
      t.string   :shared_link_id
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :scorecards, [:account_id]
    add_index :scorecards, [:deleted_at]
  end
end

class CreateWickedProblems < ActiveRecord::Migration[5.0]
  def change
    create_table :wicked_problems do |t|
      t.string   :name
      t.string   :description
      t.integer  :client_id
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :wicked_problems, [:client_id]
    add_index :wicked_problems, [:deleted_at]
  end
end

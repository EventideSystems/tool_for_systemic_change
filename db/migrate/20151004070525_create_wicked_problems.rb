class CreateWickedProblems < ActiveRecord::Migration
  def change
    create_table :wicked_problems do |t|
      t.string :name
      t.string :description
      t.references :client
      t.timestamps null: false
    end

    add_column :scorecards, :wicked_problem_id, :integer
  end
end

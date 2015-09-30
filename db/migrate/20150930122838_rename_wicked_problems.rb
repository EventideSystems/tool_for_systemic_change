class RenameWickedProblems < ActiveRecord::Migration
  def change
    rename_table :wicked_problems, :scorecards
    rename_column :initiatives, :wicked_problem_id, :scorecard_id
  end
end

class RenameInitiativeProblemId < ActiveRecord::Migration
  def change
    rename_column :initiatives, :problem_id, :wicked_problem_id
  end
end

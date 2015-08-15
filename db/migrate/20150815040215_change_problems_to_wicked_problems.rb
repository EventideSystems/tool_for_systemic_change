# Per issue #29 Change "Problems" to "Wicked Problems" in data model
class ChangeProblemsToWickedProblems < ActiveRecord::Migration
  def change
    rename_table :problems, :wicked_problems
    add_column :wicked_problems, :administrating_organisation_id, :integer
  end
end

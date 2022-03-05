class AddLinkedScorecardIdToScorecards < ActiveRecord::Migration[6.1]
  def change
    add_column :scorecards, :linked_scorecard_id, :integer
  end
end

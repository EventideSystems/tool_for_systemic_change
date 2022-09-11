class CreateScorecardChanges < ActiveRecord::Migration[7.0]
  def change
    create_view :scorecard_changes
  end
end

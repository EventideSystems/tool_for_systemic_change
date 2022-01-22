class AddTypeToScorecards < ActiveRecord::Migration[6.1]
  def change
    add_column :scorecards, :type, :string, default: 'TransitionCard'
    add_index :scorecards, :type
  end
end

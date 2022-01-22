class AddScorecardTypeToFocusAreaGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :focus_area_groups, :scorecard_type, :string, default: 'TransitionCard'
    add_index :focus_area_groups, :scorecard_type
  end
end

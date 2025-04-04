class DeprecateFocusAreaGroupsScorecardType < ActiveRecord::Migration[8.0]
  def change
    rename_column :focus_area_groups, :scorecard_type, :deprecated_scorecard_type
  end
end

# Refactor focus_areas color columns to match other models 
class NormalizeFocusAreaColorColumns < ActiveRecord::Migration[8.0]
  def change
    remove_column :focus_areas, :planned_color, :string
    rename_column :focus_areas, :actual_color, :color
  end
end

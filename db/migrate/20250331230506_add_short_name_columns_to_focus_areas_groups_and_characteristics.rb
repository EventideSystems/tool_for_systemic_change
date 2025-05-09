class AddShortNameColumnsToFocusAreasGroupsAndCharacteristics < ActiveRecord::Migration[8.0]
  def change
    add_column :focus_areas, :short_name, :string
    add_column :focus_area_groups, :short_name, :string
    add_column :characteristics, :short_name, :string
  end
end

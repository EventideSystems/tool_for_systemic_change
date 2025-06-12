class AddCodeColumnsToFocusAreasAndGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :focus_areas, :code, :string
    add_column :focus_area_groups, :code, :string
    add_column :characteristics, :code, :string
  end
end

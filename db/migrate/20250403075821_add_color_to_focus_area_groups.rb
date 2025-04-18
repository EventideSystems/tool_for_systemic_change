class AddColorToFocusAreaGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :focus_area_groups, :color, :string
  end
end

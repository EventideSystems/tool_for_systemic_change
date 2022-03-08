class UpdateFocusAreaColorFields < ActiveRecord::Migration[6.1]
  def change
    rename_column :focus_areas, :base_color, :actual_color
    add_column :focus_areas, :planned_color, :string
  end
end

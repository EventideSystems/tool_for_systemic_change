class AddBaseColorToFocusAreas < ActiveRecord::Migration[6.1]
  def change
    add_column :focus_areas, :base_color, :string
  end
end

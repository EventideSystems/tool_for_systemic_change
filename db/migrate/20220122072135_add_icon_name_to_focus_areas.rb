class AddIconNameToFocusAreas < ActiveRecord::Migration[6.1]
  def change
    add_column :focus_areas, :icon_name, :string, default: "", null: true
  end
end

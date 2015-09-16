class SimplifyModelClasses < ActiveRecord::Migration
  def change
    rename_table :model_focus_area_groups, :focus_area_groups
    rename_table :model_focus_areas, :focus_areas
    rename_table :model_initiative_characteristics, :characteristics

    rename_table :initiative_checklist_items, :checklist_items
    rename_column :checklist_items, :initiative_characteristic_id, :characteristic_id
  end
end

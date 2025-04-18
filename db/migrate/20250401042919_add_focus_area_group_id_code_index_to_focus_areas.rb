class AddFocusAreaGroupIdCodeIndexToFocusAreas < ActiveRecord::Migration[8.0]
  def change
    add_index :focus_areas,
      [:focus_area_group_id, :code], 
      unique: true, 
      name: 'index_focus_areas_on_focus_area_group_id_and_code',
      nulls_not_distinct: false
  end
end

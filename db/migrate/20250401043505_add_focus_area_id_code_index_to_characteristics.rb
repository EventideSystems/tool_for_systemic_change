class AddFocusAreaIdCodeIndexToCharacteristics < ActiveRecord::Migration[8.0]
  def change
    add_index :characteristics,
      [:focus_area_id, :code], 
      unique: true, 
      name: 'index_characteristics_on_focus_area_id_and_code',
      nulls_not_distinct: false
  end
end

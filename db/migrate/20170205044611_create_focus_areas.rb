class CreateFocusAreas < ActiveRecord::Migration[5.0]
  def change
    create_table :focus_areas do |t|
      t.string   :name
      t.string   :description
      t.integer  :focus_area_group_id
      t.integer  :position
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :focus_areas, [:deleted_at]
    add_index :focus_areas, [:focus_area_group_id]
    add_index :focus_areas, [:position]
  end
end

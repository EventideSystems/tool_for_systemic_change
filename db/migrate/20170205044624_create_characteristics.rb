class CreateCharacteristics < ActiveRecord::Migration[5.0]
  def change
    create_table :characteristics do |t|
      t.string   :name
      t.string   :description
      t.integer  :focus_area_id
      t.integer  :position
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :characteristics, [:deleted_at]
    add_index :characteristics, [:focus_area_id]
    add_index :characteristics, [:position]
  end
end

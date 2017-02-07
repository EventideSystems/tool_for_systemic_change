class CreateFocusAreaGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :focus_area_groups do |t|
      t.string   :name
      t.string   :description
      t.integer  :position
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :focus_area_groups, [:deleted_at]
    add_index :focus_area_groups, [:position]
  end
end

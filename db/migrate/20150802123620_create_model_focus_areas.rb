class CreateModelFocusAreas < ActiveRecord::Migration
  def change
    create_table :model_focus_areas do |t|
      t.string :name
      t.string :description
      t.references :focus_area_group
      t.timestamps null: false
    end
  end
end

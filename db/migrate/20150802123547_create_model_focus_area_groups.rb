class CreateModelFocusAreaGroups < ActiveRecord::Migration
  def change
    create_table :model_focus_area_groups do |t|
      t.string :name
      t.string :description
      t.timestamps null: false
    end
  end
end

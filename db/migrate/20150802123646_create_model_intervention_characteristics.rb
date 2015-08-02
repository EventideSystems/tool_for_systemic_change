class CreateModelInterventionCharacteristics < ActiveRecord::Migration
  def change
    create_table :model_intervention_characteristics do |t|
      t.string :name
      t.string :description
      t.references :focus_area
      t.timestamps null: false
    end
  end
end

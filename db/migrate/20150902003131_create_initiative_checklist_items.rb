class CreateInitiativeChecklistItems < ActiveRecord::Migration
  def change
    create_table :checklist_items do |t|
      t.boolean :checked
      t.text :comment
      t.references :initiative_characteristic
      t.references :initiative
      t.timestamps null: false
    end
  end
end

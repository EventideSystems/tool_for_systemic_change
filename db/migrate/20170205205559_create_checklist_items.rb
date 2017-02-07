class CreateChecklistItems < ActiveRecord::Migration[5.0]
  def change
    create_table :checklist_items, force: :cascade do |t|
      t.boolean  :checked
      t.text     :comment
      t.integer  :characteristic_id
      t.integer  :initiative_id
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :checklist_items, [:characteristic_id]
    add_index :checklist_items, [:deleted_at]
    add_index :checklist_items, [:initiative_id]
  end
end

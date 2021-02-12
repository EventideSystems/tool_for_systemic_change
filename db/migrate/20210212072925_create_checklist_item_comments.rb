class CreateChecklistItemComments < ActiveRecord::Migration[6.0]
  def change
    create_table :checklist_item_comments do |t|
      t.references :checklist_item, index: true
      t.string :comment
      t.datetime :deleted_at
      t.timestamps
    end
  end
end

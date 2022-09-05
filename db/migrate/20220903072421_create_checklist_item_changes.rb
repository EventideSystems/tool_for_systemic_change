class CreateChecklistItemChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :checklist_item_changes do |t|
      t.references :checklist_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :starting_status
      t.string :ending_status
      t.string :comment
      t.string :action
      t.string :activity
      t.datetime :created_at
    end
  end
end

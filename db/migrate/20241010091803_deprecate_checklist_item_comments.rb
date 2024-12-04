class DeprecateChecklistItemComments < ActiveRecord::Migration[7.1]
  def change
    rename_table :checklist_item_comments, :deprecated_checklist_item_comments
  end
end

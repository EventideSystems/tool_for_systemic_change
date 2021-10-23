class AddStatusEnumToChecklistItemComments < ActiveRecord::Migration[6.1]
  def change
    add_column :checklist_item_comments, :status, :string, default: :actual, index: true
  end
end

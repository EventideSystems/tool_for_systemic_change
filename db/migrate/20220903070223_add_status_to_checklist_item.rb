class AddStatusToChecklistItem < ActiveRecord::Migration[7.0]
  def change
    add_column :checklist_items, :status, :string, default: 'no_comment'
  end
end

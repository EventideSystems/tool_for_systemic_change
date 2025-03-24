# frozen_string_literal: true

# Remove unused view
class DropChecklistItemFirstCheckeds < ActiveRecord::Migration[8.0]
  def change
    drop_view :checklist_item_first_checkeds
  end
end

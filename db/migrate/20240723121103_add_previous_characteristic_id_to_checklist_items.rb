class AddPreviousCharacteristicIdToChecklistItems < ActiveRecord::Migration[7.0]
  def change
    add_reference :checklist_items, :previous_characteristic, foreign_key: { to_table: :characteristics }
  end
end

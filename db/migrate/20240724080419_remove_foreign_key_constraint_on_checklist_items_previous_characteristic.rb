class RemoveForeignKeyConstraintOnChecklistItemsPreviousCharacteristic < ActiveRecord::Migration[7.0]
  def change
    if foreign_key_exists?(:checklist_items, :previous_characteristic_id)
      remove_foreign_key :checklist_items, :previous_characteristic_id
    end
  end
end

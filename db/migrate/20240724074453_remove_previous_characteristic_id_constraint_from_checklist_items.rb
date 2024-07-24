class RemovePreviousCharacteristicIdConstraintFromChecklistItems < ActiveRecord::Migration[7.0]
  def change
    remove_index :checklist_items, :previous_characteristic_id
  end
end

class RenameInitiativeNotesToOldNotes < ActiveRecord::Migration[6.1]
  def change
    rename_column :initiatives, :notes, :old_notes
  end
end

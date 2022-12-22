class RenameSectorsToStakeholderTypes < ActiveRecord::Migration[7.0]
  def change
    rename_table :sectors, :stakeholder_types
    rename_column :accounts, :sector_id, :stakeholder_type_id
    rename_column :organisations, :sector_id, :stakeholder_type_id
  end
end

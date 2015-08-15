# Per issue #14 Rename InterventionCharacteristic to InitiativeCharacteristic
class RenameInterventionCharacteristic < ActiveRecord::Migration
  def change
    rename_table :model_intervention_characteristics, :model_initiative_characteristics
  end
end

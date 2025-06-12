class UpdateScorecardTypeCharacteristicsToVersion8 < ActiveRecord::Migration[8.0]
  def up
    update_view :scorecard_type_characteristics, version: 8
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot revert to previous version of scorecard_type_characteristics view"
  end
end

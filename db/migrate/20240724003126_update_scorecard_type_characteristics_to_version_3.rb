class UpdateScorecardTypeCharacteristicsToVersion3 < ActiveRecord::Migration[7.0]
  def up
    execute('DROP MATERIALIZED VIEW IF EXISTS scorecard_type_characteristics')
    create_view :scorecard_type_characteristics,
      version: 3,
      materialized: false
  end

  def down
    execute('DROP VIEW IF EXISTS scorecard_type_characteristics')
    create_view :scorecard_type_characteristics,
      version: 2,
      materialized: true
  end
end

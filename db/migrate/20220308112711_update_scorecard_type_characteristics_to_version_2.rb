class UpdateScorecardTypeCharacteristicsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    drop_view :scorecard_type_characteristics
    create_view :scorecard_type_characteristics,
      version: 2,
      materialized: true
  end
end

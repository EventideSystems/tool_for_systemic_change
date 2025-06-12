class UpdateScorecardTypeCharacteristicsToVersion8 < ActiveRecord::Migration[8.0]
  def change
    update_view :scorecard_type_characteristics, version: 8, revert_to_version: 7
  end
end

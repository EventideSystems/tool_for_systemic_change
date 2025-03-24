class UpdateScorecardTypeCharacteristicsToVersion5 < ActiveRecord::Migration[8.0]
  def change
    update_view :scorecard_type_characteristics, version: 5, revert_to_version: 4
  end
end

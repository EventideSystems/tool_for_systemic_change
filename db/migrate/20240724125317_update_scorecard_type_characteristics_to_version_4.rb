class UpdateScorecardTypeCharacteristicsToVersion4 < ActiveRecord::Migration[7.0]
  def change
    update_view :scorecard_type_characteristics, version: 4, revert_to_version: 3
  end
end

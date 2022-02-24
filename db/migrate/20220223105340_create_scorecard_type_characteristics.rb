class CreateScorecardTypeCharacteristics < ActiveRecord::Migration[6.1]
  def change
    create_view :scorecard_type_characteristics
  end
end

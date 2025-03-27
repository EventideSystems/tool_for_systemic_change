class AddImpactCardDataModelReferenceToScorecards < ActiveRecord::Migration[8.0]
  def change
    add_reference :scorecards, :impact_card_data_model, foreign_key: true
  end
end

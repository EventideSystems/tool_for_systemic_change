class AddImpactCardDataModelReferenceToScorecards < ActiveRecord::Migration[8.0]
  def change
    add_reference :scorecards, :data_model, foreign_key: true
  end
end

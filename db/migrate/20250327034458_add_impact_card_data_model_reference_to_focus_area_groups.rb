class AddImpactCardDataModelReferenceToFocusAreaGroups < ActiveRecord::Migration[8.0]
  def change
    add_reference :focus_area_groups, :data_model, foreign_key: true
  end
end

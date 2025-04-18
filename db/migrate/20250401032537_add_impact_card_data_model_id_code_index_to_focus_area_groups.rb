class AddImpactCardDataModelIdCodeIndexToFocusAreaGroups < ActiveRecord::Migration[8.0]
  def change
    add_index :focus_area_groups,
       [:impact_card_data_model_id, :code], 
       unique: true, 
       name: 'index_focus_area_groups_on_impact_card_data_model_id_and_code',
       nulls_not_distinct: false
  end
end

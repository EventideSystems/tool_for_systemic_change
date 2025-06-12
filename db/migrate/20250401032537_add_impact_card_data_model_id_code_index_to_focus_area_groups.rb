class AddImpactCardDataModelIdCodeIndexToFocusAreaGroups < ActiveRecord::Migration[8.0]
  def change
    add_index :focus_area_groups,
       [:data_model_id, :code], 
       unique: true, 
       name: 'index_focus_area_groups_on_data_model_id_and_code',
       nulls_not_distinct: false
  end
end

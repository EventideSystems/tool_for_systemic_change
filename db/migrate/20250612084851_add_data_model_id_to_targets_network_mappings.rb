class AddDataModelIdToTargetsNetworkMappings < ActiveRecord::Migration[8.0]
  def change
    add_column :targets_network_mappings, :data_model_id, :bigint, null: true
  end
end

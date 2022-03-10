class CreateTargetsNetworkMappings < ActiveRecord::Migration[6.1]
  def change
    create_table :targets_network_mappings do |t|
      t.belongs_to :focus_area, index: true
      t.belongs_to :characteristic, index: true
      t.timestamps
    end
  end
end

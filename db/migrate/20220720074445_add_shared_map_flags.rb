class AddSharedMapFlags < ActiveRecord::Migration[6.1]
  def change
    add_column :scorecards, :share_ecosystem_map, :boolean, default: true
    add_column :scorecards, :share_thematic_network_map, :boolean, default: true
  end
end

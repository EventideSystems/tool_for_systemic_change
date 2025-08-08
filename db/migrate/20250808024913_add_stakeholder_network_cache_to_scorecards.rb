class AddStakeholderNetworkCacheToScorecards < ActiveRecord::Migration[8.0]
  def change
    add_column :scorecards, :stakeholder_network_cache, :jsonb, default: {}, null: false
  end
end


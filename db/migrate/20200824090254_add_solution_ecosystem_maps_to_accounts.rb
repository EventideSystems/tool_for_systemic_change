class AddSolutionEcosystemMapsToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :solution_ecosystem_maps, :boolean
  end
end

class AddAuthorAndLicenseToImpactCardDataModels < ActiveRecord::Migration[8.0]
  def change
    add_column :impact_card_data_models, :author, :string
    add_column :impact_card_data_models, :license, :string 
  end
end

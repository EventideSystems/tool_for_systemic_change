class AddAuthorAndLicenseToImpactCardDataModels < ActiveRecord::Migration[8.0]
  def change
    add_column :data_models, :author, :string
    add_column :data_models, :license, :string 
  end
end

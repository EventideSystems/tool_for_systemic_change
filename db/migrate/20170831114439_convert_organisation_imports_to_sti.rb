class ConvertOrganisationImportsToSti < ActiveRecord::Migration[5.0]
  def change
    rename_table :organisations_imports, :imports
    add_column :imports, :type, :string
  end
end

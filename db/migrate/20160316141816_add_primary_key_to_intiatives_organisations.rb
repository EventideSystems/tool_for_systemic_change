class AddPrimaryKeyToIntiativesOrganisations < ActiveRecord::Migration
  def change
    add_column :initiatives_organisations, :id, :primary_key
  end
end

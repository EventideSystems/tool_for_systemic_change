class AddSectorAndWeblinkFieldsToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :sector_id, :integer
    add_column :organisations, :weblink, :string
  end
end

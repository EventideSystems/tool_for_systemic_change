class CreateInitiativesOrganisations < ActiveRecord::Migration[5.0]
  def change
    create_table :initiatives_organisations do |t|
      t.integer  :initiative_id,   null: false
      t.integer  :organisation_id, null: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :initiatives_organisations, [:deleted_at]
    add_index :initiatives_organisations, [:initiative_id, :organisation_id],
      unique: true,
      name: 'index_initiatives_organisations_on_initiative_organisation_id'
  end
end

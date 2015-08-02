class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :description
      t.string :type
      t.references :administrating_organisation
      t.timestamps null: false
    end
  end
end

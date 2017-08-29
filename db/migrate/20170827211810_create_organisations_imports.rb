class CreateOrganisationsImports < ActiveRecord::Migration[5.0]
  def change
    create_table :organisations_imports do |t|
      t.references :account
      t.references :user
      t.text :import_data
      t.integer :status, default: 0
      t.timestamps
    end
  end
end

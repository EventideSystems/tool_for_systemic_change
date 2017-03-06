class CreateOrganisations < ActiveRecord::Migration[5.0]
  def change
    create_table :organisations do |t|
      t.string   :name
      t.string   :description
      t.integer  :account_id
      t.integer  :sector_id
      t.string   :weblink
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :organisations, [:account_id]
    add_index :organisations, [:deleted_at]
  end
end

class CreateInitiatives < ActiveRecord::Migration[5.0]
  def change
    create_table :initiatives do |t|
      t.string   :name
      t.string   :description
      t.integer  :scorecard_id
      t.date     :started_at
      t.date     :finished_at
      t.boolean  :dates_confirmed
      t.string   :contact_name
      t.string   :contact_email
      t.string   :contact_phone
      t.string   :contact_website
      t.string   :contact_position
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :initiatives, [:deleted_at]
    add_index :initiatives, [:scorecard_id]
  end
end

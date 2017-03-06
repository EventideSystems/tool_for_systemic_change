class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string   :name
      t.string   :description
      t.string   :weblink
      t.integer  :sector_id
      t.text     :welcome_message
      t.boolean  :deactivated
      t.datetime :deleted_at
      t.timestamps
    end
  end
end

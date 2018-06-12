class CreateSubsystemTags < ActiveRecord::Migration[5.0]
  def change
    create_table :subsystem_tags do |t|
      t.string   :name
      t.string   :description
      t.integer  :account_id
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :subsystem_tags, [:account_id]
    add_index :subsystem_tags, [:deleted_at]
  end
end

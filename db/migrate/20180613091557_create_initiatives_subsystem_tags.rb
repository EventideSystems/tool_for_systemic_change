class CreateInitiativesSubsystemTags < ActiveRecord::Migration[5.0]
  def change
    create_table :initiatives_subsystem_tags do |t|
      t.integer  :initiative_id,   null: false
      t.integer  :subsystem_tag_id, null: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :initiatives_subsystem_tags, [:deleted_at]
    add_index :initiatives_subsystem_tags, [:initiative_id, :subsystem_tag_id],
      unique: true,
      name: 'idx_initiatives_subsystem_tags_initiative_and_subsystem_tag_id'
  end
end

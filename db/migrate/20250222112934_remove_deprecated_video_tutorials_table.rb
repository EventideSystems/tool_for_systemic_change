class RemoveDeprecatedVideoTutorialsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table "deprecated_video_tutorials", id: :serial, force: :cascade do |t|
      t.integer "linked_id"
      t.string "linked_type"
      t.string "link_url"
      t.string "name"
      t.text "description"
      t.boolean "promote_to_dashboard"
      t.integer "position"
      t.datetime "deleted_at", precision: nil
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["deleted_at"], name: "index_deprecated_video_tutorials_on_deleted_at"
      t.index ["linked_type", "linked_id"], name: "index_deprecated_video_tutorials_on_linked_type_and_linked_id"
    end
  end
end

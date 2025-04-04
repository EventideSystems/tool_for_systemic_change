class DropImports < ActiveRecord::Migration[8.0]
  def change
    drop_table "imports", id: :serial, force: :cascade do |t|
      t.integer "workspace_id"
      t.integer "user_id"
      t.text "import_data"
      t.integer "status", default: 0
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "type"
      t.index ["user_id"], name: "index_imports_on_user_id"
      t.index ["workspace_id"], name: "index_imports_on_workspace_id"
    end
  end
end

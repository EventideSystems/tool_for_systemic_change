# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170827211810) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "weblink"
    t.integer  "sector_id"
    t.text     "welcome_message"
    t.boolean  "deactivated"
    t.datetime "deleted_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.date     "expires_on"
    t.integer  "max_users",       default: 1
    t.integer  "max_scorecards",  default: 1
  end

  create_table "accounts_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "account_id"
    t.integer  "account_role", default: 0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["account_id", "user_id"], name: "index_accounts_users_on_account_id_and_user_id", unique: true, using: :btree
    t.index ["account_id"], name: "index_accounts_users_on_account_id", using: :btree
    t.index ["user_id"], name: "index_accounts_users_on_user_id", using: :btree
  end

  create_table "activities", force: :cascade do |t|
    t.string   "trackable_type"
    t.integer  "trackable_id"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "key"
    t.text     "parameters"
    t.string   "recipient_type"
    t.integer  "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.index ["account_id"], name: "index_activities_on_account_id", using: :btree
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
  end

  create_table "characteristics", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "focus_area_id"
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["deleted_at"], name: "index_characteristics_on_deleted_at", using: :btree
    t.index ["focus_area_id"], name: "index_characteristics_on_focus_area_id", using: :btree
    t.index ["position"], name: "index_characteristics_on_position", using: :btree
  end

  create_table "checklist_items", force: :cascade do |t|
    t.boolean  "checked"
    t.text     "comment"
    t.integer  "characteristic_id"
    t.integer  "initiative_id"
    t.datetime "deleted_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["characteristic_id"], name: "index_checklist_items_on_characteristic_id", using: :btree
    t.index ["deleted_at"], name: "index_checklist_items_on_deleted_at", using: :btree
    t.index ["initiative_id"], name: "index_checklist_items_on_initiative_id", using: :btree
  end

  create_table "communities", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "account_id"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["account_id"], name: "index_communities_on_account_id", using: :btree
    t.index ["deleted_at"], name: "index_communities_on_deleted_at", using: :btree
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "focus_area_groups", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["deleted_at"], name: "index_focus_area_groups_on_deleted_at", using: :btree
    t.index ["position"], name: "index_focus_area_groups_on_position", using: :btree
  end

  create_table "focus_areas", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "focus_area_group_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "position"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_focus_areas_on_deleted_at", using: :btree
    t.index ["focus_area_group_id"], name: "index_focus_areas_on_focus_area_group_id", using: :btree
    t.index ["position"], name: "index_focus_areas_on_position", using: :btree
  end

  create_table "initiatives", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "scorecard_id"
    t.date     "started_at"
    t.date     "finished_at"
    t.boolean  "dates_confirmed"
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.string   "contact_website"
    t.string   "contact_position"
    t.datetime "deleted_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["deleted_at"], name: "index_initiatives_on_deleted_at", using: :btree
    t.index ["scorecard_id"], name: "index_initiatives_on_scorecard_id", using: :btree
  end

  create_table "initiatives_organisations", force: :cascade do |t|
    t.integer  "initiative_id",   null: false
    t.integer  "organisation_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["deleted_at"], name: "index_initiatives_organisations_on_deleted_at", using: :btree
    t.index ["initiative_id", "organisation_id"], name: "index_initiatives_organisations_on_initiative_organisation_id", unique: true, using: :btree
  end

  create_table "organisations", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "account_id"
    t.integer  "sector_id"
    t.string   "weblink"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["account_id"], name: "index_organisations_on_account_id", using: :btree
    t.index ["deleted_at"], name: "index_organisations_on_deleted_at", using: :btree
  end

  create_table "organisations_imports", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.text     "import_data"
    t.integer  "status",      default: 0
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["account_id"], name: "index_organisations_imports_on_account_id", using: :btree
    t.index ["user_id"], name: "index_organisations_imports_on_user_id", using: :btree
  end

  create_table "scorecards", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "community_id"
    t.integer  "account_id"
    t.integer  "wicked_problem_id"
    t.string   "shared_link_id"
    t.datetime "deleted_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["account_id"], name: "index_scorecards_on_account_id", using: :btree
    t.index ["deleted_at"], name: "index_scorecards_on_deleted_at", using: :btree
  end

  create_table "sectors", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invited_by_id"
    t.integer  "invitations_count",      default: 0
    t.datetime "deleted_at"
    t.string   "profile_picture"
    t.integer  "system_role",            default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "(deleted_at IS NULL)", using: :btree
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
    t.index ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
    t.index ["name"], name: "index_users_on_name", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["system_role"], name: "index_users_on_system_role", using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  create_table "video_tutorials", force: :cascade do |t|
    t.integer  "linked_id"
    t.string   "linked_type"
    t.string   "link_url"
    t.string   "name"
    t.text     "description"
    t.boolean  "promote_to_dashboard"
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["deleted_at"], name: "index_video_tutorials_on_deleted_at", using: :btree
    t.index ["linked_type", "linked_id"], name: "index_video_tutorials_on_linked_type_and_linked_id", using: :btree
  end

  create_table "wicked_problems", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "account_id"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["account_id"], name: "index_wicked_problems_on_account_id", using: :btree
    t.index ["deleted_at"], name: "index_wicked_problems_on_deleted_at", using: :btree
  end

end

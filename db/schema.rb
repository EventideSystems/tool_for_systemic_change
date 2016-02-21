# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160221110447) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["client_id"], name: "index_activities_on_client_id", using: :btree
  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "characteristics", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "focus_area_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "position"
  end

  add_index "characteristics", ["focus_area_id"], name: "index_characteristics_on_focus_area_id", using: :btree
  add_index "characteristics", ["position"], name: "index_characteristics_on_position", using: :btree

  create_table "checklist_items", force: :cascade do |t|
    t.boolean  "checked"
    t.text     "comment"
    t.integer  "characteristic_id"
    t.integer  "initiative_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "checklist_items", ["characteristic_id"], name: "index_checklist_items_on_characteristic_id", using: :btree
  add_index "checklist_items", ["initiative_id"], name: "index_checklist_items_on_initiative_id", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "weblink"
    t.integer  "sector_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "welcome_message"
  end

  create_table "communities", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "client_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "communities", ["client_id"], name: "index_communities_on_client_id", using: :btree

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
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "focus_area_groups", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "position"
  end

  add_index "focus_area_groups", ["position"], name: "index_focus_area_groups_on_position", using: :btree

  create_table "focus_areas", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "focus_area_group_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "position"
  end

  add_index "focus_areas", ["focus_area_group_id"], name: "index_focus_areas_on_focus_area_group_id", using: :btree
  add_index "focus_areas", ["position"], name: "index_focus_areas_on_position", using: :btree

  create_table "initiatives", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "scorecard_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.date     "started_at"
    t.date     "finished_at"
    t.boolean  "dates_confirmed"
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.string   "contact_website"
    t.string   "contact_position"
  end

  add_index "initiatives", ["scorecard_id"], name: "index_initiatives_on_scorecard_id", using: :btree

  create_table "initiatives_organisations", id: false, force: :cascade do |t|
    t.integer "initiative_id",   null: false
    t.integer "organisation_id", null: false
  end

  add_index "initiatives_organisations", ["initiative_id", "organisation_id"], name: "initiatives_organisations_index", unique: true, using: :btree

  create_table "organisations", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "client_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "sector_id"
    t.string   "weblink"
  end

  add_index "organisations", ["client_id"], name: "index_organisations_on_client_id", using: :btree

  create_table "scorecards", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "community_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "client_id"
    t.integer  "wicked_problem_id"
    t.string   "shared_link_id"
  end

  add_index "scorecards", ["client_id"], name: "index_scorecards_on_client_id", using: :btree

  create_table "sectors", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sectors", ["name"], name: "index_sectors_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "client_id"
    t.integer  "role",                   default: 0
    t.string   "name"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
  end

  add_index "users", ["client_id"], name: "index_users_on_client_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "video_tutorials", force: :cascade do |t|
    t.integer  "linked_id"
    t.string   "linked_type"
    t.string   "link_url"
    t.string   "name"
    t.text     "description"
    t.boolean  "promote_to_dashboard"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "position"
  end

  add_index "video_tutorials", ["linked_type", "linked_id"], name: "index_video_tutorials_on_linked_type_and_linked_id", using: :btree

  create_table "wicked_problems", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "client_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "wicked_problems", ["client_id"], name: "index_wicked_problems_on_client_id", using: :btree

end

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

ActiveRecord::Schema.define(version: 20151004070525) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "characteristics", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "focus_area_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "checklist_items", force: :cascade do |t|
    t.boolean  "checked"
    t.text     "comment"
    t.integer  "characteristic_id"
    t.integer  "initiative_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "weblink"
    t.integer  "sector_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "communities", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "client_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "focus_area_groups", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "focus_areas", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "focus_area_group_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "initiatives", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "scorecard_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "initiatives_organisations", id: false, force: :cascade do |t|
    t.integer "initiative_id",   null: false
    t.integer "organisation_id", null: false
  end

  create_table "organisations", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "client_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "sector_id"
    t.string   "weblink"
  end

  create_table "scorecards", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "community_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "client_id"
    t.integer  "wicked_problem_id"
  end

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

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "wicked_problems", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "client_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end

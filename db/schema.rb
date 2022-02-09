# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_22_072135) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "tablefunc"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "weblink"
    t.integer "sector_id"
    t.text "welcome_message"
    t.boolean "deactivated"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "expires_on"
    t.integer "max_users", default: 1
    t.integer "max_scorecards", default: 1
    t.boolean "solution_ecosystem_maps"
    t.boolean "allow_transition_cards", default: true
    t.boolean "allow_sustainable_development_goal_alignment_cards", default: false
  end

  create_table "accounts_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "account_id"
    t.integer "account_role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "user_id"], name: "index_accounts_users_on_account_id_and_user_id", unique: true
    t.index ["account_id"], name: "index_accounts_users_on_account_id"
    t.index ["user_id"], name: "index_accounts_users_on_user_id"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.string "trackable_type"
    t.integer "trackable_id"
    t.string "owner_type"
    t.integer "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.index ["account_id"], name: "index_activities_on_account_id"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable"
  end

  create_table "characteristics", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "focus_area_id"
    t.integer "position"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_characteristics_on_deleted_at"
    t.index ["focus_area_id"], name: "index_characteristics_on_focus_area_id"
    t.index ["position"], name: "index_characteristics_on_position"
  end

  create_table "checklist_item_comments", force: :cascade do |t|
    t.bigint "checklist_item_id"
    t.string "comment"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "actual"
    t.index ["checklist_item_id"], name: "index_checklist_item_comments_on_checklist_item_id"
  end

  create_table "checklist_items", id: :serial, force: :cascade do |t|
    t.boolean "checked"
    t.text "comment"
    t.integer "characteristic_id"
    t.integer "initiative_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["characteristic_id"], name: "index_checklist_items_on_characteristic_id"
    t.index ["deleted_at"], name: "index_checklist_items_on_deleted_at"
    t.index ["initiative_id"], name: "index_checklist_items_on_initiative_id"
  end

  create_table "communities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "account_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_communities_on_account_id"
    t.index ["deleted_at"], name: "index_communities_on_deleted_at"
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "focus_area_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "position"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scorecard_type", default: "TransitionCard"
    t.index ["deleted_at"], name: "index_focus_area_groups_on_deleted_at"
    t.index ["position"], name: "index_focus_area_groups_on_position"
    t.index ["scorecard_type"], name: "index_focus_area_groups_on_scorecard_type"
  end

  create_table "focus_areas", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "focus_area_group_id"
    t.integer "position"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon_name", default: ""
    t.index ["deleted_at"], name: "index_focus_areas_on_deleted_at"
    t.index ["focus_area_group_id"], name: "index_focus_areas_on_focus_area_group_id"
    t.index ["position"], name: "index_focus_areas_on_position"
  end

  create_table "imports", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "user_id"
    t.text "import_data"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["account_id"], name: "index_imports_on_account_id"
    t.index ["user_id"], name: "index_imports_on_user_id"
  end

  create_table "initiatives", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "scorecard_id"
    t.date "started_at"
    t.date "finished_at"
    t.boolean "dates_confirmed"
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "contact_website"
    t.string "contact_position"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "old_notes"
    t.index ["deleted_at"], name: "index_initiatives_on_deleted_at"
    t.index ["finished_at"], name: "index_initiatives_on_finished_at"
    t.index ["name"], name: "index_initiatives_on_name"
    t.index ["scorecard_id"], name: "index_initiatives_on_scorecard_id"
    t.index ["started_at"], name: "index_initiatives_on_started_at"
  end

  create_table "initiatives_organisations", id: :serial, force: :cascade do |t|
    t.integer "initiative_id", null: false
    t.integer "organisation_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_initiatives_organisations_on_deleted_at"
    t.index ["initiative_id", "organisation_id"], name: "index_initiatives_organisations_on_initiative_organisation_id", unique: true
  end

  create_table "initiatives_subsystem_tags", id: :serial, force: :cascade do |t|
    t.integer "initiative_id", null: false
    t.integer "subsystem_tag_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_initiatives_subsystem_tags_on_deleted_at"
    t.index ["initiative_id", "subsystem_tag_id"], name: "idx_initiatives_subsystem_tags_initiative_and_subsystem_tag_id", unique: true
  end

  create_table "organisations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "account_id"
    t.integer "sector_id"
    t.string "weblink"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_organisations_on_account_id"
    t.index ["deleted_at"], name: "index_organisations_on_deleted_at"
  end

  create_table "scorecards", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "community_id"
    t.integer "account_id"
    t.integer "wicked_problem_id"
    t.string "shared_link_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", default: "TransitionCard"
    t.index ["account_id"], name: "index_scorecards_on_account_id"
    t.index ["deleted_at"], name: "index_scorecards_on_deleted_at"
    t.index ["type"], name: "index_scorecards_on_type"
  end

  create_table "sectors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
  end

  create_table "subsystem_tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "account_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_subsystem_tags_on_account_id"
    t.index ["deleted_at"], name: "index_subsystem_tags_on_deleted_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.datetime "deleted_at"
    t.string "profile_picture"
    t.integer "system_role", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "time_zone", default: "Adelaide"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "(deleted_at IS NULL)"
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["name"], name: "index_users_on_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["system_role"], name: "index_users_on_system_role"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "old_object"
    t.datetime "created_at"
    t.integer "account_id"
    t.jsonb "object"
    t.index ["account_id"], name: "index_versions_on_account_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "video_tutorials", id: :serial, force: :cascade do |t|
    t.integer "linked_id"
    t.string "linked_type"
    t.string "link_url"
    t.string "name"
    t.text "description"
    t.boolean "promote_to_dashboard"
    t.integer "position"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_video_tutorials_on_deleted_at"
    t.index ["linked_type", "linked_id"], name: "index_video_tutorials_on_linked_type_and_linked_id"
  end

  create_table "wicked_problems", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "account_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_wicked_problems_on_account_id"
    t.index ["deleted_at"], name: "index_wicked_problems_on_deleted_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"

  create_view "checklist_item_first_checkeds", sql_definition: <<-SQL
      SELECT checklist_items.id AS checklist_item_id,
          CASE
              WHEN (previous_versions.created_at IS NULL) THEN checklist_items.updated_at
              ELSE last_versions.created_at
          END AS first_checked_at
     FROM ((checklist_items
       LEFT JOIN ( SELECT DISTINCT ON (versions.item_id) versions.id,
              versions.item_type,
              versions.item_id,
              versions.event,
              versions.whodunnit,
              versions.old_object,
              versions.created_at,
              versions.account_id,
              versions.object
             FROM versions
            WHERE (((versions.item_type)::text = 'ChecklistItem'::text) AND ((versions.object ->> 'checked'::text) IS NULL))
            ORDER BY versions.item_id, versions.created_at DESC) last_versions ON ((last_versions.item_id = checklist_items.id)))
       LEFT JOIN ( SELECT DISTINCT ON (versions.item_id) versions.id,
              versions.item_type,
              versions.item_id,
              versions.event,
              versions.whodunnit,
              versions.old_object,
              versions.created_at,
              versions.account_id,
              versions.object
             FROM versions
            WHERE (((versions.item_type)::text = 'ChecklistItem'::text) AND ((versions.object ->> 'checked'::text) = 'true'::text))
            ORDER BY versions.item_id, versions.created_at) previous_versions ON (((previous_versions.item_id = checklist_items.id) AND (previous_versions.created_at > last_versions.created_at))))
    WHERE (((previous_versions.object ->> 'checked'::text) = 'true'::text) OR (((previous_versions.object ->> 'checked'::text) IS NULL) AND (checklist_items.checked = true)))
    ORDER BY checklist_items.id;
  SQL
  create_view "checklist_item_updated_comments_view", sql_definition: <<-SQL
      SELECT DISTINCT ON (versions.id) 'updated_comment'::text AS event,
      checklist_item_comments.checklist_item_id,
      COALESCE((next_versions.object ->> 'comment'::text), (checklist_item_comments.comment)::text) AS comment,
      COALESCE(((next_versions.object ->> 'updated_at'::text))::timestamp without time zone, checklist_item_comments.updated_at) AS occuring_at,
      (versions.object ->> 'status'::text) AS from_status,
      COALESCE((next_versions.object ->> 'status'::text), (checklist_item_comments.status)::text) AS to_status
     FROM ((versions
       LEFT JOIN versions next_versions ON (((versions.item_id = next_versions.item_id) AND ((versions.item_type)::text = (next_versions.item_type)::text) AND (versions.id < next_versions.id))))
       JOIN checklist_item_comments ON (((versions.item_id = checklist_item_comments.id) AND ((versions.item_type)::text = 'ChecklistItemComment'::text) AND ((versions.event)::text = 'update'::text) AND ((versions.object ->> 'status'::text) IS NOT NULL))));
  SQL
  create_view "events_checklist_item_first_comments", sql_definition: <<-SQL
      SELECT DISTINCT ON (checklist_items.id) 'first_comment'::text AS event,
      checklist_items.id AS checklist_item_id,
      COALESCE((versions.object ->> 'comment'::text), (checklist_item_comments.comment)::text) AS comment,
      COALESCE(((versions.object ->> 'created_at'::text))::timestamp without time zone, checklist_item_comments.created_at) AS occurred_at,
      NULL::text AS from_status,
      COALESCE((versions.object ->> 'status'::text), (checklist_item_comments.status)::text) AS to_status
     FROM ((checklist_items
       JOIN checklist_item_comments ON ((checklist_items.id = checklist_item_comments.checklist_item_id)))
       LEFT JOIN versions ON (((checklist_item_comments.id = versions.item_id) AND ((versions.item_type)::text = 'ChecklistItemComment'::text) AND ((versions.event)::text = 'update'::text))))
    ORDER BY checklist_items.id DESC, checklist_item_comments.created_at, versions.created_at;
  SQL
  create_view "events_checklist_item_updated_comments", sql_definition: <<-SQL
      SELECT DISTINCT ON (versions.id) 'updated_comment'::text AS event,
      checklist_item_comments.checklist_item_id,
      COALESCE((next_versions.object ->> 'comment'::text), (checklist_item_comments.comment)::text) AS comment,
      COALESCE(((next_versions.object ->> 'updated_at'::text))::timestamp without time zone, checklist_item_comments.updated_at) AS occurred_at,
      (versions.object ->> 'status'::text) AS from_status,
      COALESCE((next_versions.object ->> 'status'::text), (checklist_item_comments.status)::text) AS to_status
     FROM ((versions
       LEFT JOIN versions next_versions ON (((versions.item_id = next_versions.item_id) AND ((versions.item_type)::text = (next_versions.item_type)::text) AND (versions.id < next_versions.id))))
       JOIN checklist_item_comments ON (((versions.item_id = checklist_item_comments.id) AND ((versions.item_type)::text = 'ChecklistItemComment'::text) AND ((versions.event)::text = 'update'::text) AND ((versions.object ->> 'status'::text) IS NOT NULL))));
  SQL
  create_view "events_checklist_item_checkeds", sql_definition: <<-SQL
      SELECT DISTINCT ON (versions.id) 'updated_checked'::text AS event,
      checklist_items.id AS checklist_item_id,
      ''::text AS comment,
      COALESCE(((next_versions.object ->> 'updated_at'::text))::timestamp without time zone, checklist_items.updated_at) AS occurred_at,
          CASE (versions.object ->> 'checked'::text)
              WHEN 'true'::text THEN 'checked'::text
              ELSE 'unchecked'::text
          END AS from_status,
          CASE COALESCE(((next_versions.object ->> 'checked'::text) = 'true'::text), checklist_items.checked)
              WHEN true THEN 'checked'::text
              ELSE 'unchecked'::text
          END AS to_status
     FROM ((versions
       LEFT JOIN versions next_versions ON (((versions.item_id = next_versions.item_id) AND ((versions.item_type)::text = (next_versions.item_type)::text) AND ((next_versions.object ->> 'checked'::text) IS NOT NULL) AND (versions.id < next_versions.id))))
       JOIN checklist_items ON (((versions.item_id = checklist_items.id) AND ((versions.item_type)::text = 'ChecklistItem'::text) AND ((versions.event)::text = 'update'::text) AND (
          CASE (versions.object ->> 'checked'::text)
              WHEN 'true'::text THEN 'checked'::text
              ELSE 'unchecked'::text
          END <>
          CASE COALESCE(((next_versions.object ->> 'checked'::text) = 'true'::text), checklist_items.checked)
              WHEN true THEN 'checked'::text
              ELSE 'unchecked'::text
          END))));
  SQL
  create_view "events_checklist_item_new_comments", sql_definition: <<-SQL
      SELECT DISTINCT ON (checklist_item_comments.id) 'new_comment'::text AS event,
      checklist_items.id AS checklist_item_id,
      COALESCE((versions.object ->> 'comment'::text), (checklist_item_comments.comment)::text) AS comment,
      COALESCE(((versions.object ->> 'created_at'::text))::timestamp without time zone, checklist_item_comments.created_at) AS occurred_at,
      NULL::text AS from_status,
      COALESCE((versions.object ->> 'status'::text), (checklist_item_comments.status)::text) AS to_status
     FROM (((checklist_items
       JOIN checklist_item_comments ON ((checklist_items.id = checklist_item_comments.checklist_item_id)))
       LEFT JOIN versions ON (((checklist_item_comments.id = versions.item_id) AND ((versions.item_type)::text = 'ChecklistItemComment'::text) AND ((versions.event)::text = 'update'::text))))
       JOIN checklist_item_comments previous_comments ON (((checklist_items.id = previous_comments.checklist_item_id) AND (previous_comments.id < checklist_item_comments.id))))
    ORDER BY checklist_item_comments.id DESC, checklist_item_comments.created_at, versions.created_at;
  SQL
  create_view "events_checklist_item_activities", sql_definition: <<-SQL
      SELECT events_checklist_item_first_comments.event,
      events_checklist_item_first_comments.checklist_item_id,
      events_checklist_item_first_comments.comment,
      events_checklist_item_first_comments.occurred_at,
      events_checklist_item_first_comments.from_status,
      events_checklist_item_first_comments.to_status
     FROM events_checklist_item_first_comments
  UNION
   SELECT events_checklist_item_updated_comments.event,
      events_checklist_item_updated_comments.checklist_item_id,
      events_checklist_item_updated_comments.comment,
      events_checklist_item_updated_comments.occurred_at,
      events_checklist_item_updated_comments.from_status,
      events_checklist_item_updated_comments.to_status
     FROM events_checklist_item_updated_comments
  UNION
   SELECT events_checklist_item_new_comments.event,
      events_checklist_item_new_comments.checklist_item_id,
      events_checklist_item_new_comments.comment,
      events_checklist_item_new_comments.occurred_at,
      events_checklist_item_new_comments.from_status,
      events_checklist_item_new_comments.to_status
     FROM events_checklist_item_new_comments
  UNION
   SELECT events_checklist_item_checkeds.event,
      events_checklist_item_checkeds.checklist_item_id,
      events_checklist_item_checkeds.comment,
      events_checklist_item_checkeds.occurred_at,
      events_checklist_item_checkeds.from_status,
      events_checklist_item_checkeds.to_status
     FROM events_checklist_item_checkeds;
  SQL
  create_view "events_transition_card_activities", sql_definition: <<-SQL
      SELECT events_transition_card_activities_v02.transition_card_id,
      events_transition_card_activities_v02.transition_card_name,
      events_transition_card_activities_v02.initiative_id,
      events_transition_card_activities_v02.initiative_name,
      events_transition_card_activities_v02.characteristic_name,
      events_transition_card_activities_v02.event,
      events_transition_card_activities_v02.comment,
      events_transition_card_activities_v02.occurred_at,
      events_transition_card_activities_v02.from_status,
      events_transition_card_activities_v02.to_status
     FROM ( SELECT scorecards.id AS transition_card_id,
              scorecards.name AS transition_card_name,
              initiatives.id AS initiative_id,
              initiatives.name AS initiative_name,
              characteristics.name AS characteristic_name,
              events_checklist_item_activities.event,
              events_checklist_item_activities.comment,
              events_checklist_item_activities.occurred_at,
              events_checklist_item_activities.from_status,
              events_checklist_item_activities.to_status
             FROM ((((events_checklist_item_activities
               JOIN checklist_items ON ((checklist_items.id = events_checklist_item_activities.checklist_item_id)))
               JOIN characteristics ON ((characteristics.id = checklist_items.characteristic_id)))
               JOIN initiatives ON ((initiatives.id = checklist_items.initiative_id)))
               JOIN scorecards ON ((scorecards.id = initiatives.scorecard_id)))
          UNION
           SELECT scorecards.id AS transition_card_id,
              scorecards.name AS transition_card_name,
              initiatives.id AS initiative_id,
              initiatives.name AS initiative_name,
              NULL::character varying,
              'initiative_created'::text,
              NULL::text,
              initiatives.created_at,
              NULL::text,
              NULL::text
             FROM (initiatives
               JOIN scorecards ON ((scorecards.id = initiatives.scorecard_id)))
          UNION
           SELECT scorecards.id AS transition_card_id,
              scorecards.name AS transition_card_name,
              initiatives.id AS initiative_id,
              initiatives.name AS initiative_name,
              NULL::character varying,
              'initiative_deleted'::text,
              NULL::text,
              initiatives.deleted_at,
              NULL::text,
              NULL::text
             FROM (initiatives
               JOIN scorecards ON ((scorecards.id = initiatives.scorecard_id)))
            WHERE (initiatives.deleted_at IS NOT NULL)
          UNION
           SELECT scorecards.id AS transition_card_id,
              scorecards.name AS transition_card_name,
              NULL::integer,
              NULL::character varying,
              NULL::character varying,
              'transition_card_created'::text,
              NULL::text,
              scorecards.created_at,
              NULL::text,
              NULL::text
             FROM scorecards) events_transition_card_activities_v02;
  SQL
end

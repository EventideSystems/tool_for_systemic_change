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

ActiveRecord::Schema[8.0].define(version: 2025_04_03_084735) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "tablefunc"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
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
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "workspace_id"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["workspace_id"], name: "index_activities_on_workspace_id"
  end

  create_table "characteristics", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "focus_area_id"
    t.integer "position"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "code"
    t.string "short_name"
    t.index ["deleted_at"], name: "index_characteristics_on_deleted_at"
    t.index ["focus_area_id", "code"], name: "index_characteristics_on_focus_area_id_and_code", unique: true
    t.index ["focus_area_id"], name: "index_characteristics_on_focus_area_id"
    t.index ["position"], name: "index_characteristics_on_position"
  end

  create_table "checklist_item_changes", force: :cascade do |t|
    t.bigint "checklist_item_id", null: false
    t.bigint "user_id", null: false
    t.string "starting_status"
    t.string "ending_status"
    t.string "comment"
    t.string "action"
    t.string "activity"
    t.datetime "created_at"
    t.index ["checklist_item_id"], name: "index_checklist_item_changes_on_checklist_item_id"
    t.index ["user_id"], name: "index_checklist_item_changes_on_user_id"
  end

  create_table "checklist_items", id: :serial, force: :cascade do |t|
    t.boolean "checked"
    t.text "comment"
    t.integer "characteristic_id"
    t.integer "initiative_id"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status", default: "no_comment"
    t.bigint "user_id"
    t.bigint "previous_characteristic_id"
    t.index ["characteristic_id"], name: "index_checklist_items_on_characteristic_id"
    t.index ["deleted_at"], name: "index_checklist_items_on_deleted_at"
    t.index ["initiative_id"], name: "index_checklist_items_on_initiative_id"
    t.index ["user_id"], name: "index_checklist_items_on_user_id"
  end

  create_table "communities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "workspace_id"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "color", default: "#14b8a6", null: false
    t.index ["deleted_at"], name: "index_communities_on_deleted_at"
    t.index ["workspace_id"], name: "index_communities_on_workspace_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "deprecated_checklist_item_comments", force: :cascade do |t|
    t.bigint "checklist_item_id"
    t.string "comment"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "actual"
    t.index ["checklist_item_id"], name: "index_deprecated_checklist_item_comments_on_checklist_item_id"
  end

  create_table "focus_area_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "position"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "deprecated_scorecard_type", default: "TransitionCard"
    t.bigint "workspace_id"
    t.bigint "impact_card_data_model_id"
    t.string "code"
    t.string "short_name"
    t.string "color"
    t.index ["deleted_at"], name: "index_focus_area_groups_on_deleted_at"
    t.index ["deprecated_scorecard_type"], name: "index_focus_area_groups_on_deprecated_scorecard_type"
    t.index ["impact_card_data_model_id", "code"], name: "index_focus_area_groups_on_impact_card_data_model_id_and_code", unique: true
    t.index ["impact_card_data_model_id"], name: "index_focus_area_groups_on_impact_card_data_model_id"
    t.index ["position"], name: "index_focus_area_groups_on_position"
    t.index ["workspace_id"], name: "index_focus_area_groups_on_workspace_id"
  end

  create_table "focus_areas", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "focus_area_group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "position"
    t.datetime "deleted_at", precision: nil
    t.string "icon_name", default: ""
    t.string "actual_color"
    t.string "planned_color"
    t.string "code"
    t.string "short_name"
    t.index ["deleted_at"], name: "index_focus_areas_on_deleted_at"
    t.index ["focus_area_group_id", "code"], name: "index_focus_areas_on_focus_area_group_id_and_code", unique: true
    t.index ["focus_area_group_id"], name: "index_focus_areas_on_focus_area_group_id"
    t.index ["position"], name: "index_focus_areas_on_position"
  end

  create_table "impact_card_data_models", force: :cascade do |t|
    t.string "name", null: false
    t.string "short_name"
    t.string "description"
    t.string "status", default: "active", null: false
    t.string "color", default: "#0d9488", null: false
    t.bigint "workspace_id"
    t.boolean "system_model", default: false
    t.datetime "deleted_at"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "workspace_id"], name: "index_impact_card_data_models_on_name_and_workspace_id", unique: true, where: "((workspace_id IS NOT NULL) AND (deleted_at IS NULL))"
    t.index ["workspace_id"], name: "index_impact_card_data_models_on_workspace_id"
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
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "old_notes"
    t.boolean "linked", default: false
    t.datetime "archived_on"
    t.index ["archived_on"], name: "index_initiatives_on_archived_on"
    t.index ["deleted_at"], name: "index_initiatives_on_deleted_at"
    t.index ["finished_at"], name: "index_initiatives_on_finished_at"
    t.index ["name"], name: "index_initiatives_on_name"
    t.index ["scorecard_id"], name: "index_initiatives_on_scorecard_id"
    t.index ["started_at"], name: "index_initiatives_on_started_at"
  end

  create_table "initiatives_organisations", id: :serial, force: :cascade do |t|
    t.integer "initiative_id", null: false
    t.integer "organisation_id", null: false
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_initiatives_organisations_on_deleted_at"
    t.index ["initiative_id", "organisation_id"], name: "index_initiatives_organisations_on_initiative_organisation_id", unique: true
    t.index ["initiative_id"], name: "index_initiatives_organisations_on_initiative_id"
  end

  create_table "initiatives_subsystem_tags", id: :serial, force: :cascade do |t|
    t.integer "initiative_id", null: false
    t.integer "subsystem_tag_id", null: false
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_initiatives_subsystem_tags_on_deleted_at"
    t.index ["initiative_id", "subsystem_tag_id"], name: "idx_initiatives_subsystem_tags_initiative_and_subsystem_tag_id", unique: true
  end

  create_table "organisations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "workspace_id"
    t.integer "stakeholder_type_id"
    t.string "weblink"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_organisations_on_deleted_at"
    t.index ["workspace_id"], name: "index_organisations_on_workspace_id"
  end

  create_table "scorecards", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "community_id"
    t.integer "workspace_id"
    t.integer "wicked_problem_id"
    t.string "shared_link_id"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "deprecated_type", default: "TransitionCard"
    t.integer "linked_scorecard_id"
    t.boolean "share_ecosystem_map", default: true
    t.boolean "share_thematic_network_map", default: true
    t.bigint "impact_card_data_model_id"
    t.index ["deleted_at"], name: "index_scorecards_on_deleted_at"
    t.index ["deprecated_type"], name: "index_scorecards_on_deprecated_type"
    t.index ["impact_card_data_model_id"], name: "index_scorecards_on_impact_card_data_model_id"
    t.index ["workspace_id"], name: "index_scorecards_on_workspace_id"
  end

  create_table "stakeholder_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "color"
    t.integer "workspace_id"
    t.index ["workspace_id"], name: "index_stakeholder_types_on_workspace_id"
  end

  create_table "subsystem_tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "workspace_id"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "color", default: "#14b8a6", null: false
    t.index ["deleted_at"], name: "index_subsystem_tags_on_deleted_at"
    t.index ["workspace_id"], name: "index_subsystem_tags_on_workspace_id"
  end

  create_table "targets_network_mappings", force: :cascade do |t|
    t.bigint "focus_area_id"
    t.bigint "characteristic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["characteristic_id"], name: "index_targets_network_mappings_on_characteristic_id"
    t.index ["focus_area_id"], name: "index_targets_network_mappings_on_focus_area_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.datetime "deleted_at", precision: nil
    t.string "profile_picture"
    t.integer "system_role", default: 0
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "time_zone", default: "Adelaide"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "(deleted_at IS NULL)"
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
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
    t.datetime "created_at", precision: nil
    t.integer "workspace_id"
    t.jsonb "object"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["workspace_id"], name: "index_versions_on_workspace_id"
  end

  create_table "wicked_problems", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "workspace_id"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "color", default: "#14b8a6", null: false
    t.index ["deleted_at"], name: "index_wicked_problems_on_deleted_at"
    t.index ["workspace_id"], name: "index_wicked_problems_on_workspace_id"
  end

  create_table "workspaces", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "deprecated_weblink"
    t.text "deprecated_welcome_message"
    t.boolean "deactivated"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "expires_on"
    t.integer "max_users", default: 1
    t.integer "max_scorecards", default: 1
    t.boolean "deprecated_solution_ecosystem_maps"
    t.boolean "deprecated_allow_transition_cards", default: true
    t.boolean "deprecated_allow_sustainable_development_goal_alignment_cards", default: false
    t.date "expiry_warning_sent_on"
    t.string "transition_card_model_name", default: "Transition Card"
    t.string "transition_card_focus_area_group_model_name", default: "Focus Area Group"
    t.string "transition_card_focus_area_model_name", default: "Focus Area"
    t.string "transition_card_characteristic_model_name", default: "Characteristic"
    t.string "sdgs_alignment_card_model_name", default: "SDGs Alignment Card"
    t.string "sdgs_alignment_card_focus_area_group_model_name", default: "Focus Area Group"
    t.string "sdgs_alignment_card_focus_area_model_name", default: "Focus Area"
    t.string "sdgs_alignment_card_characteristic_model_name", default: "Targets"
    t.boolean "classic_grid_mode", default: false
  end

  create_table "workspaces_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "workspace_id"
    t.integer "workspace_role", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_workspaces_users_on_user_id"
    t.index ["workspace_id", "user_id"], name: "index_workspaces_users_on_workspace_id_and_user_id", unique: true
    t.index ["workspace_id"], name: "index_workspaces_users_on_workspace_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "checklist_item_changes", "checklist_items"
  add_foreign_key "checklist_item_changes", "users"
  add_foreign_key "checklist_items", "characteristics", column: "previous_characteristic_id"
  add_foreign_key "checklist_items", "users"
  add_foreign_key "focus_area_groups", "impact_card_data_models"
  add_foreign_key "focus_area_groups", "workspaces"
  add_foreign_key "impact_card_data_models", "workspaces"
  add_foreign_key "scorecards", "impact_card_data_models"

  create_view "checklist_item_updated_comments_view", sql_definition: <<-SQL
      SELECT DISTINCT ON (versions.id) 'updated_comment'::text AS event,
      deprecated_checklist_item_comments.checklist_item_id,
      COALESCE((next_versions.object ->> 'comment'::text), (deprecated_checklist_item_comments.comment)::text) AS comment,
      COALESCE(((next_versions.object ->> 'updated_at'::text))::timestamp without time zone, deprecated_checklist_item_comments.updated_at) AS occuring_at,
      (versions.object ->> 'status'::text) AS from_status,
      COALESCE((next_versions.object ->> 'status'::text), (deprecated_checklist_item_comments.status)::text) AS to_status
     FROM ((versions
       LEFT JOIN versions next_versions ON (((versions.item_id = next_versions.item_id) AND ((versions.item_type)::text = (next_versions.item_type)::text) AND (versions.id < next_versions.id))))
       JOIN deprecated_checklist_item_comments ON (((versions.item_id = deprecated_checklist_item_comments.id) AND ((versions.item_type)::text = 'ChecklistItemComment'::text) AND ((versions.event)::text = 'update'::text) AND ((versions.object ->> 'status'::text) IS NOT NULL))));
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
  create_view "events_checklist_item_first_comments", sql_definition: <<-SQL
      SELECT DISTINCT ON (checklist_items.id) 'first_comment'::text AS event,
      checklist_items.id AS checklist_item_id,
      COALESCE((versions.object ->> 'comment'::text), (deprecated_checklist_item_comments.comment)::text) AS comment,
      COALESCE(((versions.object ->> 'created_at'::text))::timestamp without time zone, deprecated_checklist_item_comments.created_at) AS occurred_at,
      NULL::text AS from_status,
      COALESCE((versions.object ->> 'status'::text), (deprecated_checklist_item_comments.status)::text) AS to_status
     FROM ((checklist_items
       JOIN deprecated_checklist_item_comments ON ((checklist_items.id = deprecated_checklist_item_comments.checklist_item_id)))
       LEFT JOIN versions ON (((deprecated_checklist_item_comments.id = versions.item_id) AND ((versions.item_type)::text = 'ChecklistItemComment'::text) AND ((versions.event)::text = 'update'::text))))
    ORDER BY checklist_items.id DESC, deprecated_checklist_item_comments.created_at, versions.created_at;
  SQL
  create_view "events_checklist_item_new_comments", sql_definition: <<-SQL
      SELECT DISTINCT ON (deprecated_checklist_item_comments.id) 'new_comment'::text AS event,
      checklist_items.id AS checklist_item_id,
      COALESCE((versions.object ->> 'comment'::text), (deprecated_checklist_item_comments.comment)::text) AS comment,
      COALESCE(((versions.object ->> 'created_at'::text))::timestamp without time zone, deprecated_checklist_item_comments.created_at) AS occurred_at,
      NULL::text AS from_status,
      COALESCE((versions.object ->> 'status'::text), (deprecated_checklist_item_comments.status)::text) AS to_status
     FROM (((checklist_items
       JOIN deprecated_checklist_item_comments ON ((checklist_items.id = deprecated_checklist_item_comments.checklist_item_id)))
       LEFT JOIN versions ON (((deprecated_checklist_item_comments.id = versions.item_id) AND ((versions.item_type)::text = 'ChecklistItemComment'::text) AND ((versions.event)::text = 'update'::text))))
       JOIN deprecated_checklist_item_comments previous_comments ON (((checklist_items.id = previous_comments.checklist_item_id) AND (previous_comments.id < deprecated_checklist_item_comments.id))))
    ORDER BY deprecated_checklist_item_comments.id DESC, deprecated_checklist_item_comments.created_at, versions.created_at;
  SQL
  create_view "events_checklist_item_updated_comments", sql_definition: <<-SQL
      SELECT DISTINCT ON (versions.id) 'updated_comment'::text AS event,
      deprecated_checklist_item_comments.checklist_item_id,
      COALESCE((next_versions.object ->> 'comment'::text), (deprecated_checklist_item_comments.comment)::text) AS comment,
      COALESCE(((next_versions.object ->> 'updated_at'::text))::timestamp without time zone, deprecated_checklist_item_comments.updated_at) AS occurred_at,
      (versions.object ->> 'status'::text) AS from_status,
      COALESCE((next_versions.object ->> 'status'::text), (deprecated_checklist_item_comments.status)::text) AS to_status
     FROM ((versions
       LEFT JOIN versions next_versions ON (((versions.item_id = next_versions.item_id) AND ((versions.item_type)::text = (next_versions.item_type)::text) AND (versions.id < next_versions.id))))
       JOIN deprecated_checklist_item_comments ON (((versions.item_id = deprecated_checklist_item_comments.id) AND ((versions.item_type)::text = 'ChecklistItemComment'::text) AND ((versions.event)::text = 'update'::text) AND ((versions.object ->> 'status'::text) IS NOT NULL))));
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
      SELECT transition_card_id,
      transition_card_name,
      initiative_id,
      initiative_name,
      characteristic_name,
      event,
      comment,
      occurred_at,
      from_status,
      to_status
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
              NULL::character varying AS "varchar",
              'initiative_created'::text AS text,
              NULL::text AS text,
              initiatives.created_at,
              NULL::text AS text,
              NULL::text AS text
             FROM (initiatives
               JOIN scorecards ON ((scorecards.id = initiatives.scorecard_id)))
          UNION
           SELECT scorecards.id AS transition_card_id,
              scorecards.name AS transition_card_name,
              initiatives.id AS initiative_id,
              initiatives.name AS initiative_name,
              NULL::character varying AS "varchar",
              'initiative_deleted'::text AS text,
              NULL::text AS text,
              initiatives.deleted_at,
              NULL::text AS text,
              NULL::text AS text
             FROM (initiatives
               JOIN scorecards ON ((scorecards.id = initiatives.scorecard_id)))
            WHERE (initiatives.deleted_at IS NOT NULL)
          UNION
           SELECT scorecards.id AS transition_card_id,
              scorecards.name AS transition_card_name,
              NULL::integer AS int4,
              NULL::character varying AS "varchar",
              NULL::character varying AS "varchar",
              'transition_card_created'::text AS text,
              NULL::text AS text,
              scorecards.created_at,
              NULL::text AS text,
              NULL::text AS text
             FROM scorecards) events_transition_card_activities_v02;
  SQL
  create_view "scorecard_changes", sql_definition: <<-SQL
      SELECT initiatives.scorecard_id,
      initiatives.created_at AS occurred_at,
      initiatives.name AS initiative_name,
      ''::character varying AS characteristic_name,
      'initiative_created'::character varying AS action,
      ''::character varying AS activity,
      ''::character varying AS from_value,
      ''::character varying AS to_value,
      ''::character varying AS comment
     FROM initiatives
  UNION
   SELECT initiatives.scorecard_id,
      checklist_item_changes.created_at AS occurred_at,
      initiatives.name AS initiative_name,
      characteristics.name AS characteristic_name,
      checklist_item_changes.action,
      checklist_item_changes.activity,
      checklist_item_changes.starting_status AS from_value,
      checklist_item_changes.ending_status AS to_value,
      checklist_item_changes.comment
     FROM (((checklist_item_changes
       JOIN checklist_items ON ((checklist_items.id = checklist_item_changes.checklist_item_id)))
       JOIN characteristics ON ((characteristics.id = checklist_items.characteristic_id)))
       JOIN initiatives ON ((initiatives.id = checklist_items.initiative_id)))
    ORDER BY 1, 2 DESC;
  SQL
  create_view "scorecard_type_characteristics", sql_definition: <<-SQL
      SELECT characteristics.id,
      characteristics.name,
      characteristics.description,
      characteristics.focus_area_id,
      characteristics."position",
      characteristics.deleted_at,
      characteristics.created_at,
      characteristics.updated_at,
      focus_area_groups.impact_card_data_model_id,
      focus_area_groups.workspace_id
     FROM ((characteristics
       JOIN focus_areas ON ((characteristics.focus_area_id = focus_areas.id)))
       JOIN focus_area_groups ON ((focus_areas.focus_area_group_id = focus_area_groups.id)))
    WHERE ((characteristics.deleted_at IS NULL) AND (focus_areas.deleted_at IS NULL) AND (focus_area_groups.deleted_at IS NULL))
    ORDER BY focus_areas."position", characteristics."position";
  SQL
end

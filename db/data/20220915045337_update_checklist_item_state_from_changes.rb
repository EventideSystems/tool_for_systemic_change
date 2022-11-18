# frozen_string_literal: true

class UpdateChecklistItemStateFromChanges < ActiveRecord::Migration[7.0]
  def up
    execute CLEAR_CHECKLIST_ITEM_STATE_SQL
    execute UPDATE_CHECKLIST_ITEM_STATE_SQL
  end

  def down
    # NO OP
  end

  CLEAR_CHECKLIST_ITEM_STATE_SQL = <<~SQL
    update checklist_items
    set status = 'no_comment', comment = null
  SQL

  UPDATE_CHECKLIST_ITEM_STATE_SQL = <<~SQL
    with last_checklist_item_change as (
      select
        checklist_item_changes.checklist_item_id as checklist_item_change_id,
        checklist_item_changes.*
      from checklist_items
      inner join lateral (
        select
          distinct on (checklist_item_id)
          checklist_item_id,
          ending_status,
          created_at as updated_at,
          user_id,
          comment
        from checklist_item_changes
        where checklist_item_changes.checklist_item_id = checklist_items.id
        order by checklist_item_changes.checklist_item_id, checklist_item_changes.created_at desc
      ) checklist_item_changes on true
    )
    update checklist_items
    set
      status = last_checklist_item_change.ending_status,
      updated_at = last_checklist_item_change.updated_at,
      user_id = last_checklist_item_change.user_id,
      comment = last_checklist_item_change.comment
    from last_checklist_item_change
    where checklist_items.id = last_checklist_item_change.checklist_item_id
  SQL
end

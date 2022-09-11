# frozen_string_literal: true

class UpdateChecklistItemCommentAndStatus < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_CHECKLIST_ITEM_COMMENT_AND_STATUS_SQL
  end

  def down
    # NO OP
  end

  UPDATE_CHECKLIST_ITEM_COMMENT_AND_STATUS_SQL = <<~SQL
    with checklist_item_last_entries as (
      select
        distinct on (checklist_item_id)
        checklist_item_id,
        comment,
        ending_status
      from checklist_item_changes
      order by checklist_item_id, created_at desc
    )
    update checklist_items
    set
      comment = checklist_item_last_entries.comment,
      status = checklist_item_last_entries.ending_status
    from checklist_item_last_entries
    where checklist_item_last_entries.checklist_item_id = checklist_items.id
  SQL
end

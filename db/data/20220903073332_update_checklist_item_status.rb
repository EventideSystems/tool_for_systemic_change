# frozen_string_literal: true

class UpdateChecklistItemStatus < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_FROM_RECENT_STATUS_SQL
    execute UPDATE_FROM_CHECKED_STATUS_SQL
  end

  def down
    # NO OP
  end

  UPDATE_FROM_RECENT_STATUS_SQL = <<~SQL
    with recent_status as (
      select distinct on (checklist_item_id) checklist_item_id, status
      from checklist_item_comments
      where status is not null
      order by checklist_item_id, updated_at desc
    )
    update checklist_items
    set status = recent_status.status
    from recent_status
    where checklist_items.id = recent_status.checklist_item_id;
  SQL

  UPDATE_FROM_CHECKED_STATUS_SQL = <<~SQL
    update checklist_items
    set status = 'more_information'
    where checklist_items.checked = true
    and checklist_items.status = 'no_comment';
  SQL
end

# frozen_string_literal: true

class UpdateStartingStatusForChecklistItemChanges < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_CHECKLIST_ITEM_CHANGE_STATUS_SQL
  end

  def down
    # NO OP
  end

  UPDATE_CHECKLIST_ITEM_CHANGE_STATUS_SQL = <<~SQL
    with checklist_item_change_status as (
      select
        checklist_item_changes.id as checklist_item_change_id,
        coalesce(prev_checklist_item_changes.ending_status, 'no_comment') as target_status
      from checklist_item_changes
      left join lateral (
        select
          distinct on (checklist_item_id)
          checklist_item_id,
          ending_status
        from checklist_item_changes prev_checklist_item_changes
        where prev_checklist_item_changes.checklist_item_id = checklist_item_changes.checklist_item_id
        and prev_checklist_item_changes.created_at < checklist_item_changes.created_at
        and prev_checklist_item_changes.ending_status is not null
        order by prev_checklist_item_changes.checklist_item_id, prev_checklist_item_changes.created_at desc
      ) prev_checklist_item_changes on true
      where (checklist_item_changes.starting_status is null or checklist_item_changes.starting_status = 'no_comment')
    )
    update checklist_item_changes
    set starting_status = checklist_item_change_status.target_status
    from checklist_item_change_status
    where checklist_item_changes.id = checklist_item_change_status.checklist_item_change_id
    and (checklist_item_changes.starting_status is null or checklist_item_changes.starting_status = 'no_comment')
  SQL
end


# frozen_string_literal: true

class UpdateEndingStatusForChecklistItemChanges < ActiveRecord::Migration[7.0]
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
        coalesce(next_checklist_item_changes.starting_status, checklist_item_changes.starting_status) as target_status
      from checklist_item_changes
      left join lateral (
        select
          distinct on (checklist_item_id)
          checklist_item_id,
          starting_status
        from checklist_item_changes next_checklist_item_changes
        where next_checklist_item_changes.checklist_item_id = checklist_item_changes.checklist_item_id
        and next_checklist_item_changes.created_at > checklist_item_changes.created_at
        and next_checklist_item_changes.starting_status is not null
        order by next_checklist_item_changes.checklist_item_id, next_checklist_item_changes.created_at asc
      ) next_checklist_item_changes on true
      where (checklist_item_changes.ending_status is null)
    )
    update checklist_item_changes
    set ending_status = checklist_item_change_status.target_status
    from checklist_item_change_status
    where checklist_item_changes.id = checklist_item_change_status.checklist_item_change_id
    and (checklist_item_changes.ending_status is null)
  SQL
end

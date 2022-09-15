# frozen_string_literal: true

class UpdateChecklistItemChangeActivity < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_CHECKLIST_ITEM_CHANGE_ACTIVITY_SQL
  end

  def down
    # NO OP
  end

  UPDATE_CHECKLIST_ITEM_CHANGE_ACTIVITY_SQL = <<~SQL
    with checklist_item_change_status as (
      select
        checklist_item_changes.id as checklist_item_change_id,
        case when (
          prev_checklist_item_changes.id is not null
          and checklist_item_changes.action = 'save_new_comment'
          and checklist_item_changes.starting_status = 'actual'
          and checklist_item_changes.ending_status = 'actual'
        ) then 'new_comments_saved_assigned_actuals'
        else
          case when (
            checklist_item_changes.starting_status <> 'actual'
            and checklist_item_changes.ending_status = 'actual'
          ) then 'addition'
          else
            'none'
          end
        end as target_activity
      from checklist_item_changes
      left join lateral (
        select
          distinct on (checklist_item_id)
          *
        from checklist_item_changes prev_checklist_item_changes
        where prev_checklist_item_changes.checklist_item_id = checklist_item_changes.checklist_item_id
        and prev_checklist_item_changes.created_at < checklist_item_changes.created_at
        order by prev_checklist_item_changes.checklist_item_id, prev_checklist_item_changes.created_at desc
      ) prev_checklist_item_changes on true
    )
    update checklist_item_changes
    set activity = checklist_item_change_status.target_activity
    from checklist_item_change_status
    where checklist_item_changes.id = checklist_item_change_status.checklist_item_change_id
  SQL
end

# frozen_string_literal: true

class UpdateUserForNewCommentChange < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_CHECKLIST_ITEM_CHANGE_USER_SQL
  end

  def down
    # NO OP
  end

  UPDATE_CHECKLIST_ITEM_CHANGE_USER_SQL = <<~SQL
    with checklist_item_created as (
      select
        distinct on (versions.item_id)
        item_id, whodunnit::integer from versions
      inner join users on users.id = whodunnit::integer
      where item_type = 'ChecklistItem'
      and event = 'update'
      order by versions.item_id, versions.created_at desc
    )
    update checklist_item_changes
    set user_id = checklist_item_created.whodunnit
    from checklist_item_created
    where checklist_item_created.item_id = checklist_item_changes.checklist_item_id
    and checklist_item_changes.user_id = -9
    and checklist_item_changes.action = 'save_new_comment'
    and checklist_item_changes.starting_status = 'no_comment';
  SQL
end

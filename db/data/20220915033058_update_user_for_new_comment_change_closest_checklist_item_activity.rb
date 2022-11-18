# frozen_string_literal: true

class UpdateUserForNewCommentChangeClosestChecklistItemActivity < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_CHECKLIST_ITEM_CHANGE_USER_SQL
  end

  def down
    # NO OP
  end

  UPDATE_CHECKLIST_ITEM_CHANGE_USER_SQL = <<~SQL
    with checklist_item_created as (
      select
        checklist_item_changes.id as checklist_item_id,
        whodunnit::integer as whodunnit
      from checklist_item_changes
      inner join lateral (
        select
          distinct on (versions.item_id)
          versions.item_id, whodunnit::integer from versions
          where item_type = 'ChecklistItem'
          and item_id = checklist_item_changes.checklist_item_id
          order by versions.item_id, versions.created_at desc
      ) as closest_activity on true
      where user_id = -9 and action = 'save_new_comment'
    )
    update checklist_item_changes
    set user_id = checklist_item_created.whodunnit
    from checklist_item_created
    where checklist_item_created.checklist_item_id = checklist_item_changes.id
    and checklist_item_changes.user_id = -9
  SQL
end



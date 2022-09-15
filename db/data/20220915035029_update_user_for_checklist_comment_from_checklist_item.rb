# frozen_string_literal: true

class UpdateUserForChecklistCommentFromChecklistItem < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_CHECKLIST_ITEM_CHANGE_USER_SQL
  end

  def down
    # NO OP
  end

  UPDATE_CHECKLIST_ITEM_CHANGE_USER_SQL = <<~SQL
    with checklist_item_created as (
      select
        id as checklist_item_id,
        user_id as whodunnit
      from checklist_items
    )
    update checklist_item_changes
    set user_id = checklist_item_created.whodunnit
    from checklist_item_created
    where checklist_item_created.checklist_item_id = checklist_item_changes.checklist_item_id
    and checklist_item_changes.user_id = -9;
  SQL
end

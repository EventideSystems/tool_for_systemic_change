# frozen_string_literal: true

class UpdateChecklistItemUserFromComments < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_CHECKLIST_ITEM_USER_FROM_COMMENTS_SQL
  end

  def down
     # NO OP
  end

  UPDATE_CHECKLIST_ITEM_USER_FROM_COMMENTS_SQL = <<~SQL
    with checklist_item_created as (
      select distinct on (object->>'checklist_item_id')
        (object->>'checklist_item_id')::integer as item_id,
        whodunnit::integer
      from versions
      inner join users on users.id = whodunnit::integer
      where item_type = 'ChecklistItemComment'
      and object->>'checklist_item_id' is not null
    )
    update checklist_items
    set user_id = checklist_item_created.whodunnit
    from checklist_item_created
    where checklist_item_created.item_id = checklist_items.id
    and checklist_items.user_id is null
  SQL

end

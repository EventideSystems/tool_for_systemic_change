# frozen_string_literal: true

class UpdateChecklistItemUser < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_CHECKLIST_ITEM_USER_SQL
  end

  def down
    # NO OP
  end

  UPDATE_CHECKLIST_ITEM_USER_SQL = <<~SQL
    with checklist_item_created as (
      select item_id, whodunnit::integer from versions
      where item_type = 'ChecklistItem'
      and event = 'create'
    )
    update checklist_items
    set user_id = checklist_item_created.whodunnit
    from checklist_item_created
    where checklist_item_created.item_id = checklist_items.id;
  SQL

end

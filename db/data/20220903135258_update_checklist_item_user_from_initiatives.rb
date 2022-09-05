# frozen_string_literal: true

class UpdateChecklistItemUserFromInitiatives < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_CHECKLIST_ITEM_USER_FROM_INITIATIVES_SQL
  end

  def down
     # NO OP
  end

  UPDATE_CHECKLIST_ITEM_USER_FROM_INITIATIVES_SQL = <<~SQL
    with initiative_created as (
      select
        item_id as initiative_id,
        whodunnit::integer
      from versions
      inner join users on users.id = whodunnit::integer
      where item_type = 'Initiative'
      and event = 'create'
    )
    update checklist_items
    set user_id = initiative_created.whodunnit
    from initiative_created
    where initiative_created.initiative_id = checklist_items.initiative_id
    and checklist_items.user_id is null
  SQL
end

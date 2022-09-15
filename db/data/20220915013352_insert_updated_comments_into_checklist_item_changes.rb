# frozen_string_literal: true

class InsertUpdatedCommentsIntoChecklistItemChanges < ActiveRecord::Migration[7.0]
  def up
    ActiveRecord::Base.connection.execute(INSERT_INTO_CHECKLIST_ITEM_CHANGES)
  end

  def down
    # NO OP
  end

  INSERT_INTO_CHECKLIST_ITEM_CHANGES = <<-SQL
    insert into  checklist_item_changes (
      checklist_item_id,
      user_id,
      starting_status,
      ending_status,
      comment,
      action,
      activity,
      created_at
    )
    -- update comments
    select
      distinct on (versions.id)
      checklist_item_comments.checklist_item_id as checklist_item_id,
      coalesce(next_versions.whodunnit::integer, versions.whodunnit::integer, -9) as user_id,
      versions.object->>'status' as starting_status,
      coalesce(next_versions.object->>'status', checklist_item_comments.status) as ending_status,
      coalesce(next_versions.object->>'comment', checklist_item_comments.comment) as comment,
      'update_existing' as action,
      null as activity,
      coalesce((next_versions.object->>'updated_at')::timestamp, checklist_item_comments.updated_at) as created_at
    from versions
    left join versions next_versions
      on versions.item_id = next_versions.item_id
      and versions.item_type = next_versions.item_type
      and versions.id < next_versions.id
    inner join checklist_item_comments on versions.item_id = checklist_item_comments.id and versions.item_type = 'ChecklistItemComment'
    inner join checklist_items on checklist_item_comments.checklist_item_id = checklist_items.id
    and versions.event = 'update'
    and versions.object->>'status' is not null
  SQL
end

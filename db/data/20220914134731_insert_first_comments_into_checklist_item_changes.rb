# frozen_string_literal: true

class InsertFirstCommentsIntoChecklistItemChanges < ActiveRecord::Migration[7.0]
  def up
    ActiveRecord::Base.connection.execute(CREATE_FAKE_USER)
    ActiveRecord::Base.connection.execute(INSERT_INTO_CHECKLIST_ITEM_CHANGES)
  end

  def down
    ChecklistItemChange.delete_all
    ActiveRecord::Base.connection.execute(DELETE_FAKE_USER)
  end

  CREATE_FAKE_USER = <<-SQL
    insert into users (id, email, name, created_at, updated_at)
    values (-9, 'fake@email.com', 'fake_user', now(), now())
  SQL

  DELETE_FAKE_USER = <<-SQL
    delete from users where id = -9
  SQL

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
    -- first comments
    select
      distinct on (checklist_items.id)
      checklist_items.id as checklist_item_id,
      coalesce(versions.whodunnit::integer, -9) as user_id,
      'no_comment' as starting_status,
      coalesce(versions.object->>'status', checklist_item_comments.status, 'more_information') as ending_status,
      coalesce(versions.object->>'comment', checklist_item_comments.comment) as comment,
      'save_new_comment' as action,
      null as activity,
      coalesce((versions.object->>'created_at')::timestamp, checklist_item_comments.created_at) as created_at
    from checklist_items
    inner join checklist_item_comments on checklist_items.id = checklist_item_comments.checklist_item_id
    left join versions
      on checklist_item_comments.id = versions.item_id
      and versions.item_type = 'ChecklistItemComment'
      and versions.event = 'update'
    order by checklist_items.id desc, checklist_item_comments.created_at asc, versions.created_at asc
  SQL
end


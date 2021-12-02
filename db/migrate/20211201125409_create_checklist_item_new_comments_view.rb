class CreateChecklistItemNewCommentsView < ActiveRecord::Migration[6.1]
  def up
    connection.execute(<<~SQL)
      CREATE OR REPLACE VIEW checklist_item_new_comments_view AS
        select 
          distinct on (checklist_items.id) 
          'new_comment' as event, 
          checklist_items.id as checklist_item_id,
          coalesce(versions.object->>'comment', checklist_item_comments.comment) as comment,
          coalesce((versions.object->>'created_at')::timestamp, checklist_item_comments.created_at) as occuring_at,
          null as from_status,
          coalesce(versions.object->>'status', checklist_item_comments.status) as to_status
        from checklist_items
        inner join checklist_item_comments on checklist_items.id = checklist_item_comments.checklist_item_id
        left join versions 
          on checklist_item_comments.id = versions.item_id 
          and versions.item_type = 'ChecklistItemComment' 
          and versions.event = 'update'
        inner join checklist_item_comments previous_comments 
          on checklist_items.id = previous_comments.checklist_item_id 
          and previous_comments.id < checklist_item_comments.id
        order by checklist_items.id desc, checklist_item_comments.created_at asc, versions.created_at asc
    SQL
  end

  def down
    connection.execute(<<~SQL)
      DROP VIEW checklist_item_new_comments_view
    SQL
  end
end

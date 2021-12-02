class UpdateChecklistItemFirstCommentView < ActiveRecord::Migration[6.1]
  def up
    connection.execute(<<~SQL)
      CREATE OR REPLACE VIEW checklist_item_first_comment_view AS
      select 
        distinct on (checklist_items.id) 
        'first_comment' as event, 
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
      order by checklist_items.id desc, checklist_item_comments.created_at asc, versions.created_at asc
    SQL
  end

  def down
    connection.execute(<<~SQL)
      CREATE OR REPLACE VIEW checklist_item_first_comments AS
        select
          checklist_items.id as checklist_item_id,
          case 
            when previous_versions.created_at is null then checklist_items.comment
            else previous_versions.object->>'comment'
          end as first_comment,
          case 
            when previous_versions.created_at is null then checklist_items.updated_at
            else last_versions.created_at
          end as first_comment_at
        from checklist_items 
        inner join (
          select distinct on (item_id) * from versions
          where versions.item_type = 'ChecklistItem' 
          and (versions.object->>'comment' is null or versions.object->>'comment' = '')
          order by item_id, created_at desc
        ) as last_versions
        on last_versions.item_id = checklist_items.id
        left join (
          select distinct on (item_id) * from versions
          where versions.item_type = 'ChecklistItem' 
          and versions.object->>'comment' is not null
          order by item_id, created_at asc
        ) as previous_versions
        on previous_versions.item_id = checklist_items.id
        and previous_versions.created_at > last_versions.created_at
        where (previous_versions.object->>'comment' is not null)
          or (previous_versions.object->>'comment' is null and checklist_items.comment is not null)
        order by checklist_items.id
    SQL
  end
end

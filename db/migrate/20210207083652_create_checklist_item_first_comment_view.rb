class CreateChecklistItemFirstCommentView < ActiveRecord::Migration[6.0]
  def up
    connection.execute(<<~SQL)
      CREATE OR REPLACE VIEW checklist_item_first_comments AS
        select
          checklist_items.id,
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

  def down
    connection.execute(<<~SQL)
      DROP VIEW checklist_item_first_comments
    SQL
  end
end

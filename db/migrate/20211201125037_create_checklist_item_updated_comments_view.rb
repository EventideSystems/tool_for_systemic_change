class CreateChecklistItemUpdatedCommentsView < ActiveRecord::Migration[6.1]
  def change
    connection.execute(<<~SQL)
    CREATE OR REPLACE VIEW checklist_item_updated_comments_view AS
      select
        distinct on (versions.id) 
        'updated_comment' as event,
        checklist_item_comments.checklist_item_id as checklist_item_id,
        coalesce(next_versions.object->>'comment', checklist_item_comments.comment) as comment,
        coalesce((next_versions.object->>'updated_at')::timestamp, checklist_item_comments.updated_at) as occuring_at,
        versions.object->>'status' as from_status,
        coalesce(next_versions.object->>'status', checklist_item_comments.status) as to_status
      from versions
      left join versions next_versions 
        on versions.item_id = next_versions.item_id 
        and versions.item_type = next_versions.item_type 
        and versions.id < next_versions.id
      inner join checklist_item_comments on versions.item_id = checklist_item_comments.id and versions.item_type = 'ChecklistItemComment'
      and versions.event = 'update'
      and versions.object->>'status' is not null
    SQL
  end

  def down
    connection.execute(<<~SQL)
      DROP VIEW checklist_item_first_comments
    SQL
  end
end

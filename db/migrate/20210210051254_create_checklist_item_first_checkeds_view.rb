class CreateChecklistItemFirstCheckedsView < ActiveRecord::Migration[6.0]
  def up
    connection.execute(<<~SQL)
      CREATE OR REPLACE VIEW checklist_item_first_checkeds AS
        select
          checklist_items.id as checklist_item_id,
          case 
            when previous_versions.created_at is null then checklist_items.updated_at
            else last_versions.created_at
          end as first_checked_at
        from checklist_items 
        left join (
          select distinct on (item_id) * from versions
          where versions.item_type = 'ChecklistItem' 
          and (versions.object->>'checked' is null)
          order by item_id, created_at desc
        ) as last_versions
        on last_versions.item_id = checklist_items.id
        left join (
          select distinct on (item_id) * from versions
          where versions.item_type = 'ChecklistItem' 
          and versions.object->>'checked' = 'true'
          order by item_id, created_at asc
        ) as previous_versions
        on previous_versions.item_id = checklist_items.id
        and previous_versions.created_at > last_versions.created_at
        where (previous_versions.object->>'checked' = 'true')
          or (
            (previous_versions.object->>'checked' is null) 
            and checklist_items.checked = true
          )
        order by checklist_items.id
    SQL
  end

  def down
    connection.execute(<<~SQL)
      DROP VIEW checklist_item_first_checkeds
    SQL
  end
end

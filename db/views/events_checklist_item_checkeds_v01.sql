select
  distinct on (versions.id) 
  'updated_checked' as event,
  checklist_items.id as checklist_item_id,
  '' as comment,
  coalesce((next_versions.object->>'updated_at')::timestamp, checklist_items.updated_at) as occurred_at,
  case versions.object->>'checked'
  when 'true' then 'checked'
  else 'unchecked'
  end as from_status,
  case coalesce(next_versions.object->>'checked' = 'true', checklist_items.checked) 
  when true then 'checked'
  else 'unchecked'
  end as to_status
from versions
left join versions next_versions 
  on versions.item_id = next_versions.item_id 
  and versions.item_type = next_versions.item_type
  and next_versions.object->>'checked' is not null
  and versions.id < next_versions.id
inner join checklist_items on versions.item_id = checklist_items.id and versions.item_type = 'ChecklistItem'
and versions.event = 'update'
and (
  case versions.object->>'checked'
  when 'true' then 'checked'
  else 'unchecked'
  end
) <> (
  case coalesce(next_versions.object->>'checked' = 'true', checklist_items.checked) 
  when true then 'checked'
  else 'unchecked'
  end
)

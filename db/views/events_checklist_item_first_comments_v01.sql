select 
  distinct on (checklist_items.id) 
  'first_comment' as event, 
  checklist_items.id as checklist_item_id,
  coalesce(versions.object->>'comment', checklist_item_comments.comment) as comment,
  coalesce((versions.object->>'created_at')::timestamp, checklist_item_comments.created_at) as occurred_at,
  null as from_status,
  coalesce(versions.object->>'status', checklist_item_comments.status) as to_status
from checklist_items
inner join checklist_item_comments on checklist_items.id = checklist_item_comments.checklist_item_id
left join versions 
  on checklist_item_comments.id = versions.item_id 
  and versions.item_type = 'ChecklistItemComment' 
  and versions.event = 'update'
order by checklist_items.id desc, checklist_item_comments.created_at asc, versions.created_at asc

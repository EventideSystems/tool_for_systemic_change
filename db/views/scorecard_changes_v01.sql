select
  initiatives.scorecard_id as scorecard_id,
  created_at as occurred_at,
  initiatives.name as initiative_name,
  '' as characteristic_name,
  'initiative_created' as action,
  '' as activity,
  '' as from_value,
  '' as to_value,
  '' as comment
from initiatives

union

select
  initiatives.scorecard_id as scorecard_id,
  checklist_items.created_at as occurred_at,
  initiatives.name as initiative_name,
  characteristics.name as characteristic_name,
  checklist_item_changes.action as action,
  checklist_item_changes.activity as activity,
  checklist_item_changes.starting_status as from_value,
  checklist_item_changes.ending_status as to_value,
  checklist_item_changes.comment as comment
from checklist_item_changes
inner join checklist_items on checklist_items.id = checklist_item_changes.checklist_item_id
inner join characteristics on characteristics.id = checklist_items.characteristic_id
inner join initiatives on initiatives.id = checklist_items.initiative_id

order by scorecard_id, occurred_at desc

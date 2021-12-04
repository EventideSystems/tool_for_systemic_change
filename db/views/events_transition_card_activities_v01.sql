select
  scorecards.id as transition_card_id,
  scorecards.name as transition_card_name,
  initiatives.id as initiative_id,
  initiatives.name as initiative_name,
  characteristics.name as characteristic_name,
  events_checklist_item_activities.event,
  events_checklist_item_activities.comment,
  events_checklist_item_activities.occurred_at,
  events_checklist_item_activities.from_status,
  events_checklist_item_activities.to_status 
from events_checklist_item_activities
inner join checklist_items on checklist_items.id = events_checklist_item_activities.checklist_item_id
inner join characteristics on characteristics.id = checklist_items.characteristic_id
inner join initiatives on initiatives.id = checklist_items.initiative_id
inner join scorecards on scorecards.id = initiatives.scorecard_id

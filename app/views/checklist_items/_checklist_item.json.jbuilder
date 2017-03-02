json.extract! checklist_item, :id, :created_at, :updated_at
json.url initiative_checklist_item_url(checklist_item.initiative, checklist_item, format: :json)
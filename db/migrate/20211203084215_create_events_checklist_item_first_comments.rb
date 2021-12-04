class CreateEventsChecklistItemFirstComments < ActiveRecord::Migration[6.1]
  def change
    create_view :events_checklist_item_first_comments
  end
end

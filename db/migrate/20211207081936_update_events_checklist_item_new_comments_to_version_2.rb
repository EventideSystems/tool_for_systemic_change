class UpdateEventsChecklistItemNewCommentsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    drop_view :events_transition_card_activities
    drop_view :events_checklist_item_activities
    update_view :events_checklist_item_new_comments, version: 2, revert_to_version: 1
    create_view :events_checklist_item_activities
    create_view :events_transition_card_activities
  end
end

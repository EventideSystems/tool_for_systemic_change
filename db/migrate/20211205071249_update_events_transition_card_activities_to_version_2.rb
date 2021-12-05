class UpdateEventsTransitionCardActivitiesToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :events_transition_card_activities, version: 2, revert_to_version: 1
  end
end

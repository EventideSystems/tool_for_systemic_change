class CreateEventsTransitionCardActivities < ActiveRecord::Migration[6.1]
  def change
    create_view :events_transition_card_activities
  end
end

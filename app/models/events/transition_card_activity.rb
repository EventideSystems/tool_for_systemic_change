# == Schema Information
#
# Table name: events_transition_card_activities
#
#  characteristic_name  :string
#  comment              :text
#  event                :text
#  from_status          :text
#  initiative_name      :string
#  occurred_at          :datetime
#  to_status            :text
#  transition_card_name :string
#  initiative_id        :integer
#  transition_card_id   :integer
#
class Events::TransitionCardActivity < View
end

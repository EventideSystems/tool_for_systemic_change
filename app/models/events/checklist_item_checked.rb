# == Schema Information
#
# Table name: events_checklist_item_checkeds
#
#  comment           :text
#  event             :text
#  from_status       :text
#  occurred_at       :datetime
#  to_status         :text
#  checklist_item_id :integer
#
module Events
  class ChecklistItemChecked < View
  end
end

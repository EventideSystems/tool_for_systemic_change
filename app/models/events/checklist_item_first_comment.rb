# frozen_string_literal: true

# == Schema Information
#
# Table name: events_checklist_item_first_comments
#
#  comment           :text
#  event             :text
#  from_status       :text
#  occurred_at       :datetime
#  to_status         :text
#  checklist_item_id :integer
#
module Events
  class ChecklistItemFirstComment < View
  end
end

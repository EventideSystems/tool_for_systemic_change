# frozen_string_literal: true

# == Schema Information
#
# Table name: events_checklist_item_new_comments
#
#  comment           :text
#  event             :text
#  from_status       :text
#  occurred_at       :datetime
#  to_status         :text
#  checklist_item_id :integer

# TODO: Check that this ever gets used.
module Events
  class ChecklistItemNewComment < View
  end
end

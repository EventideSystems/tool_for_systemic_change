# frozen_string_literal: true

# == Schema Information
#
# Table name: checklist_item_changes
#
#  id                :bigint           not null, primary key
#  action            :string
#  activity          :string
#  comment           :string
#  ending_status     :string
#  starting_status   :string
#  created_at        :datetime
#  checklist_item_id :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_checklist_item_changes_on_checklist_item_id  (checklist_item_id)
#  index_checklist_item_changes_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (checklist_item_id => checklist_items.id)
#  fk_rails_...  (user_id => users.id)
#
class ChecklistItemChange < ApplicationRecord
  belongs_to :checklist_item
  belongs_to :user

  scope :per_scorecard,
        lambda { |scorecard|
          joins(checklist_item: :initiative)
            .where({ initiatives: { scorecard_id: scorecard.id } })
            .order(created_at: :desc)
        }
end

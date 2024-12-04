# frozen_string_literal: true

# == Schema Information
#
# Table name: deprecated_checklist_item_comments
#
#  id                :bigint           not null, primary key
#  comment           :string
#  deleted_at        :datetime
#  status            :string           default("actual")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  checklist_item_id :bigint
#
# Indexes
#
#  index_deprecated_checklist_item_comments_on_checklist_item_id  (checklist_item_id)
#
class DeprecatedChecklistItemComment < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  string_enum status: %i[actual planned suggestion more_information]

  belongs_to :checklist_item

  validates :status, presence: true
  validates :comment, presence: true
end

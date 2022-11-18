# frozen_string_literal: true

class ChecklistItemComment < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  string_enum status: %i[actual planned suggestion more_information]

  belongs_to :checklist_item

  validates :status, presence: true
  validates :comment, presence: true

end

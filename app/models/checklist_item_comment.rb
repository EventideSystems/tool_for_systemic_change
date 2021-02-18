# frozen_string_literal: true
class ChecklistItemComment < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :checklist_item
end

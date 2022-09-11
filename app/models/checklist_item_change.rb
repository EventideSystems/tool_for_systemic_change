# frozen_string_literal: true

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

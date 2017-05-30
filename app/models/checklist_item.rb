# frozen_string_literal: true
class ChecklistItem < ApplicationRecord
  include Trackable
  has_paper_trail
  acts_as_paranoid

  belongs_to :initiative
  belongs_to :characteristic

  validates :initiative, presence: true
  validates :characteristic, presence: true, uniqueness: { scope: :initiative }

  def name
    characteristic.name.presence
  end
end

# frozen_string_literal: true
class ChecklistItem < ApplicationRecord
  acts_as_paranoid

  include Trackable

  belongs_to :initiative
  belongs_to :characteristic

  validates :initiative, presence: true
  validates :characteristic, presence: true, uniqueness: { scope: :initiative }

  def name
    characteristic.name.presence
  end
end

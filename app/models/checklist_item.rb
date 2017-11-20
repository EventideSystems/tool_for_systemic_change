# frozen_string_literal: true
class ChecklistItem < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :initiative
  belongs_to :characteristic

  validates :initiative, presence: true
  validates :characteristic, presence: true, uniqueness: { scope: :initiative }

  def name
    characteristic.name.presence
  end
  
  def snapshot_at(timestamp)
    return self if timestamp.nil?
    paper_trail.version_at(timestamp) || raw_clone
  end
  
  private
  
  def raw_clone
    raw_clone = self.clone
    raw_clone.checked = nil
    raw_clone.readonly!
    raw_clone
  end
  
end

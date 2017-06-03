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
  
  def snapshot_at(timestamp)
    return self if timestamp.nil?
    paper_trail.version_at(timestamp) || unchecked_clone
  end
  
  private
  
  def unchecked_clone
    cloned_checklist = self.clone
    cloned_checklist.readonly!
    cloned_checklist.checked = false
    cloned_checklist
  end
  
end

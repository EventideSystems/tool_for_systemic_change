# frozen_string_literal: true
class ChecklistItem < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :initiative
  belongs_to :characteristic

  has_many :checklist_item_comments

  validates :initiative, presence: true
  validates :characteristic, presence: true, uniqueness: { scope: :initiative }

  attr_reader :new_comment # support creating comments

  def name
    characteristic.name.presence
  end
  
  def snapshot_at(timestamp)
    return self if timestamp.nil?
    paper_trail.version_at(timestamp) || raw_clone
  end
  
  def focus_area
    characteristic.focus_area
  end

  def current_checklist_item_comment
    checklist_item_comments.order(created_at: :desc).first
  end

  def current_comment
    current_checklist_item_comment&.comment
  end
  
  private
  
  def raw_clone
    raw_clone = self.clone
    raw_clone.checked = nil
    raw_clone.readonly!
    raw_clone
  end
  
end

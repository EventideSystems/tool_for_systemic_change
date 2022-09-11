# frozen_string_literal: true
class ChecklistItem < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  string_enum status: %i[no_comment actual planned more_information suggestion]

  belongs_to :user
  belongs_to :initiative
  belongs_to :characteristic

  has_many :checklist_item_comments

  has_many :checklist_item_changes, dependent: :destroy

  validates :status, presence: true
  validates :status, inclusion: { in: (statuses.keys - %w[no_comment]), message: 'Please select a status' }, on: :update
  validates :comment, presence: true
  validates :initiative, presence: true
  validates :characteristic, presence: true, uniqueness: { scope: :initiative }

  attr_reader :new_comment, :new_status # support creating comments

  attribute :humanized_status, :string

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

  def humanized_status
    status.humanize
  end

  private

  def raw_clone
    raw_clone = self.clone
    raw_clone.checked = nil
    raw_clone.readonly!
    raw_clone
  end

end

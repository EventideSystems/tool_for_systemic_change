# frozen_string_literal: true

# == Schema Information
#
# Table name: checklist_items
#
#  id                         :integer          not null, primary key
#  checked                    :boolean
#  comment                    :text
#  deleted_at                 :datetime
#  status                     :string           default("no_comment")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  characteristic_id          :integer
#  initiative_id              :integer
#  previous_characteristic_id :bigint
#  user_id                    :bigint
#
# Indexes
#
#  index_checklist_items_on_characteristic_id  (characteristic_id)
#  index_checklist_items_on_deleted_at         (deleted_at)
#  index_checklist_items_on_initiative_id      (initiative_id)
#  index_checklist_items_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (previous_characteristic_id => characteristics.id)
#  fk_rails_...  (user_id => users.id)
#
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

  delegate :focus_area, to: :characteristic
  delegate :focus_area_group, to: :focus_area

  scope :grouped_by_focus_area, -> { group_by(&:focus_area_id) }

  def name
    characteristic&.name.presence
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

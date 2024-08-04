# frozen_string_literal: true

# == Schema Information
#
# Table name: characteristics
#
#  id            :integer          not null, primary key
#  deleted_at    :datetime
#  description   :string
#  name          :string
#  position      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  focus_area_id :integer
#
# Indexes
#
#  index_characteristics_on_deleted_at     (deleted_at)
#  index_characteristics_on_focus_area_id  (focus_area_id)
#  index_characteristics_on_position       (position)
#
class Characteristic < ApplicationRecord
  acts_as_paranoid

  attr_accessor :video_tutorial_id

  default_scope { order('focus_areas.position', :position).joins(:focus_area) }

  belongs_to :focus_area
  has_one :video_tutorial, as: :linked
  has_many :checklist_items

  validates :position, presence: true, uniqueness: { scope: :focus_area }
  delegate :position, to: :focus_area, prefix: true

  delegate :scorecard_type, :account, to: :focus_area

  scope :per_scorecard_type_for_account, -> (scorecard_type, account) {
    joins(focus_area: :focus_area_group)
      .where(
        'focus_area_groups_focus_areas.scorecard_type' => scorecard_type,
        'focus_area_groups_focus_areas.account_id' => account.id
      )
  }

  def video_tutorial_id=(value)
    return if value.blank?
    tutorial = VideoTutorial.where(id: value).first
    tutorial&.update_attribute(:linked, self)
  end

  def video_tutorial_id
    video_tutorial.try(:id)
  end

  def identifier
    "#{focus_area.position}.#{self.position}"
  end

  def short_name
    name.match(/(\d*\.\d*)\s.*/)[1] || name
  end
end

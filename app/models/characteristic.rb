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
  has_one :video_tutorial, as: :linked, dependent: :destroy
  has_many :checklist_items, dependent: :nullify

  # TODO: Add scoped position validation to database schema
  validates :position, presence: true, uniqueness: { scope: :focus_area } # rubocop:disable Rails/UniqueValidationWithoutIndex
  delegate :position, to: :focus_area, prefix: true

  delegate :scorecard_type, :account, to: :focus_area

  scope :per_scorecard_type_for_account, lambda { |scorecard_type, account|
    joins(focus_area: :focus_area_group)
      .where(
        'focus_area_groups_focus_areas.scorecard_type' => scorecard_type,
        'focus_area_groups_focus_areas.account_id' => account.id
      )
  }

  def identifier
    "#{focus_area.position}.#{position}"
  end

  def short_name
    name.match(/(\d*\.\d*)\s.*/)[1] || name
  end

  # SMELL: This is a hack to allow the video_tutorial_id to be set on the
  # characteristic. This is needed because the video_tutorial has been set as a
  # "has_one" relationship, but it actually should be inverted to a "belongs_to"
  # relationship.
  #
  # This is a temporary solution until the relationship is fixed, or the video_tutorial
  # is removed from the characteristic model.
  def video_tutorial_id=(value) # rubocop:disable Lint/DuplicateMethods
    return if value.blank?

    tutorial = VideoTutorial.where(id: value).first
    tutorial&.update(linked: self)
  end

  # SMELL: See above
  def video_tutorial_id # rubocop:disable Lint/DuplicateMethods
    video_tutorial.try(:id)
  end
end

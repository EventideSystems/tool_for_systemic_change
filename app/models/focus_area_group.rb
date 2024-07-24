# frozen_string_literal: true
class FocusAreaGroup < ApplicationRecord
  acts_as_paranoid

  default_scope { order(:position) }

  attr_accessor :video_tutorial_id

  belongs_to :account, optional: true

  has_many :focus_areas, dependent: :restrict_with_error
  has_one :video_tutorial, as: :linked

  validates :position, presence: true

  def video_tutorial_id=(value)
    return if value.blank?
    tutorial = VideoTutorial.where(id: value).first
    tutorial.update_attribute(:linked, self) if tutorial
  end

  def video_tutorial_id
    video_tutorial.try(:id)
  end
end

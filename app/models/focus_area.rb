# frozen_string_literal: true
class FocusArea < ApplicationRecord
  acts_as_paranoid

  default_scope { order('focus_area_groups.position', :position).joins(:focus_area_group) }
  
  scope :ordered_by_group_position, -> { includes(:focus_area_group)
    .order('focus_area_groups.position', 'focus_areas.position')
  }

  attr_accessor :video_tutorial_id
  
  belongs_to :focus_area_group
  has_many :characteristics, -> { order(position: :desc) }, dependent: :restrict_with_error
  has_one :video_tutorial, as: :linked

  validates :position, presence: true, uniqueness: { scope: :focus_area_group }

 # accepts_nested_attributes_for :video_tutorials
  
  def video_tutorial_id=(value)
    return if value.blank?
    tutorial = VideoTutorial.where(id: value).first
    tutorial.update_attribute(:linked, self) if tutorial
  end
  
  def video_tutorial_id
    video_tutorial.try(:id)
  end

end

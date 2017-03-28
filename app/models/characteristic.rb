# frozen_string_literal: true
class Characteristic < ApplicationRecord
  acts_as_paranoid
  
  attr_accessor :video_tutorial_id

  default_scope { order(:focus_area_id, :position) }

  belongs_to :focus_area
  has_one :video_tutorial, as: :linked
  has_many :checklist_items

  validates :position, presence: true, uniqueness: { scope: :focus_area }
  
  #accepts_nested_attributes_for :video_tutorial
  
  def video_tutorial_id=(value)
    VideoTutorial.find(value).update_attribute(:linked, self)
  end
  
  def video_tutorial_id
    video_tutorial.try(:id)
  end
end

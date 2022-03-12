# frozen_string_literal: true
class Characteristic < ApplicationRecord
  acts_as_paranoid

  attr_accessor :video_tutorial_id

  default_scope { order('focus_areas.position', :position).joins(:focus_area) }

  belongs_to :focus_area
  has_one :video_tutorial, as: :linked
  has_many :checklist_items

  validates :position, presence: true, uniqueness: { scope: :focus_area }
  delegate :position, to: :focus_area, prefix: true
  #accepts_nested_attributes_for :video_tutorial

  scope :per_scorecard_type, -> (scorecard_type) {
    joins(focus_area: :focus_area_group)
      .where('focus_area_groups_focus_areas.scorecard_type' => scorecard_type)
  }

  DESCRIPTION_TEMPLATE = <<~HTML
    <h1>Initiative Characteristics</h1>
    <br/>
    <em>Details go here...</em>
    <br/>
    <h1>Why it is important</h1>
    <br/>
    <em>Details go here...</em>
    <br/>
    <h1>Examples</h1>
    <br/>
    <em>Details go here...</em>
  HTML

  def video_tutorial_id=(value)
    return if value.blank?
    tutorial = VideoTutorial.where(id: value).first
    tutorial.update_attribute(:linked, self) if tutorial
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

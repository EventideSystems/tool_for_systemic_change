# frozen_string_literal: true
class Characteristic < ApplicationRecord
  acts_as_paranoid

  default_scope { order(:focus_area_id, :position) }

  belongs_to :focus_area
  has_many :video_tutorials, as: :linked
  has_many :checklist_items

  validates :position, presence: true, uniqueness: { scope: :focus_area }

  accepts_nested_attributes_for :video_tutorials
end

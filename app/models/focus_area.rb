# frozen_string_literal: true
class FocusArea < ApplicationRecord
  acts_as_paranoid

  default_scope { order(:focus_area_group_id, :position) }

  belongs_to :focus_area_group
  has_many :characteristics, dependent: :restrict_with_error
  has_many :video_tutorials, as: :linked

  validates :position, presence: true, uniqueness: { scope: :focus_area_group }

  accepts_nested_attributes_for :video_tutorials
end

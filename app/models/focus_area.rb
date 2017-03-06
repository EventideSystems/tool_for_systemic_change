# frozen_string_literal: true
class FocusArea < ApplicationRecord
  acts_as_paranoid

  default_scope { order(:focus_area_group_id, :position) }
  
  scope :ordered_by_group_position, -> { includes(:focus_area_group)
    .order('focus_area_groups.position', 'focus_areas.position')
  }

  belongs_to :focus_area_group
  has_many :characteristics, dependent: :restrict_with_error
  has_many :video_tutorials, as: :linked

  validates :position, presence: true, uniqueness: { scope: :focus_area_group }

  accepts_nested_attributes_for :video_tutorials

end

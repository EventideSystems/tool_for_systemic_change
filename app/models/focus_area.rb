class FocusArea < ActiveRecord::Base
  default_scope { order(:focus_area_group_id, :position) }

  belongs_to :focus_area_group
  has_many  :characteristics
  has_many :video_tutorials, as: :linked

  validates :position, presence: true, uniqueness: { scope: :focus_area_group }

  accepts_nested_attributes_for :video_tutorials
end

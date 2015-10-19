class FocusArea < ActiveRecord::Base
  default_scope { order(:focus_area_group_id, :position) }

  belongs_to :focus_area_group
  has_many  :characteristics

  validates :position, presence: true, uniqueness: { scope: :focus_area_group }
end

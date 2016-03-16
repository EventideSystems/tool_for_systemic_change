class Characteristic < ActiveRecord::Base
  acts_as_paranoid

  default_scope { order(:focus_area_id, :position) }

  belongs_to :focus_area
  has_many :video_tutorials, as: :linked

  validates :position, presence: true, uniqueness: { scope: :focus_area }

  accepts_nested_attributes_for :video_tutorials
end

class Characteristic < ActiveRecord::Base
  default_scope { order(:focus_area_id, :position) }

  belongs_to :focus_area

  validates :position, presence: true, uniqueness: { scope: :focus_area }
end

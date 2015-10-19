class FocusAreaGroup < ActiveRecord::Base
  default_scope { order(:position) }

  has_many :focus_areas

  validates :position, presence: true
end

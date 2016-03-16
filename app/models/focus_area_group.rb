class FocusAreaGroup < ActiveRecord::Base
  acts_as_paranoid

  default_scope { order(:position) }

  has_many :focus_areas

  validates :position, presence: true
end

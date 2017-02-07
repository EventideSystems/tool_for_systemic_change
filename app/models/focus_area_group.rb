class FocusAreaGroup < ApplicationRecord
  acts_as_paranoid

  default_scope { order(:position) }

  has_many :focus_areas, dependent: :restrict_with_error

  validates :position, presence: true
end

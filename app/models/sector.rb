class Sector < ActiveRecord::Base
  acts_as_paranoid

  include Trackable

  has_many :organisations, class_name: "Organisation", foreign_key: "sector_id", dependent: :restrict_with_error
  has_many :clients, class_name: "Client", foreign_key: "sector_id", dependent: :restrict_with_error

  validates :name, uniqueness: true
end

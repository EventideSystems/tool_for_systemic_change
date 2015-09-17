class Sector < ActiveRecord::Base
  has_many :organisations, class_name: "Organisation", foreign_key: "sector_id"
  has_many :clients, class_name: "Client", foreign_key: "sector_id"

  validates :name, uniqueness: true
end

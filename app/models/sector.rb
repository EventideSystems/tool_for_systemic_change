class Sector < ActiveRecord::Base
  has_many :organisations

  validates :name, uniqueness: true
end

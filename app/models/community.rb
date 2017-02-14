class Community < ApplicationRecord
  acts_as_paranoid

  include Trackable
  
  belongs_to :account
  has_many :scorecards

  
end

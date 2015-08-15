class Community < ActiveRecord::Base
  belongs_to :administrating_organisation
  has_many :wicked_problems
end

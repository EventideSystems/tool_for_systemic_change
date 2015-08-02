class Problem < ActiveRecord::Base
  belongs_to :community
#  belongs_to :admistrating_organisation, through: :community
  has_many :initiatives
end

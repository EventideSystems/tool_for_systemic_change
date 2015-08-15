class WickedProblem < ActiveRecord::Base
  belongs_to :community
  belongs_to :administrating_organisation, class_name: 'AdministratingOrganisation'
  has_many :initiatives
end

class WickedProblem < ActiveRecord::Base
  belongs_to :community
  belongs_to :adminstrating_organisation, class_name: 'AdministratingOrganisation'
  has_many :initiatives
end

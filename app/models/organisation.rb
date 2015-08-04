class Organisation < ActiveRecord::Base
  belongs_to :adminstrating_organisation, class_name: 'AdministratingOrganisation'
  has_and_belongs_to_many :intiatives, join_table: :initiatives_organisations, class_name: 'Initiative'
end

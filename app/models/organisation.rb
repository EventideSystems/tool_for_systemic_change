class Organisation < ActiveRecord::Base
  belongs_to :administrating_organisation, class_name: 'AdministratingOrganisation'
  belongs_to :sector
  has_and_belongs_to_many :intiatives, join_table: :initiatives_organisations, class_name: 'Initiative'
end

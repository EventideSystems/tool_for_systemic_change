class Organisation < ActiveRecord::Base
  belongs_to :administrating_organisation, class_name: 'AdministratingOrganisation'
  belongs_to :sector
  has_and_belongs_to_many :intiatives, join_table: :initiatives_organisations, class_name: 'Initiative'


  # SMELL Having to check the type because top-level STI classes are 'nil'
  # types. Implies that we really should model these separately
  scope :no_subclasses, -> { where(type: nil) }

  # SMELL Dupe of scope in WickedProblem - move to a concern
  scope :for_user, ->(user) {
    unless user.staff?
      where(administrating_organisation_id: user.administrating_organisation.id)
    end
  }
end

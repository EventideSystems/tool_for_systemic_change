class AdministratingOrganisationSerializer < BaseSerializer
  attributes :id, :name, :description

  has_many :organisations
end

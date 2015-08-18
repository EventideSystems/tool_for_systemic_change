class AdministratingOrganisationSerializer < ActiveModel::Serializer
  attributes :id, :name, :description

  has_many :organisations
end

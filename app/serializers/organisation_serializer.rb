class OrganisationSerializer < ActiveModel::Serializer
  attributes :id, :name, :description

  belongs_to :administrating_organisation
end

class OrganisationSerializer < BaseSerializer
  attributes :id, :name, :description

  belongs_to :administrating_organisation
end

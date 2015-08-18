class CommunitySerializer < ActiveModel::Serializer
  attributes :id, :name, :description

  belongs_to :administrating_organisation
end

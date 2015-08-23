class CommunitySerializer < BaseSerializer
  attributes :id, :name, :description

  belongs_to :administrating_organisation
  has_many :wicked_problems
end

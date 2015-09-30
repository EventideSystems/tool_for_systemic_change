class CommunitySerializer < BaseSerializer
  attributes :id, :name, :description

  belongs_to :client
  has_many :scorecards
end

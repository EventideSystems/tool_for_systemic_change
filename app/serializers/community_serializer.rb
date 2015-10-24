class CommunitySerializer < BaseSerializer
  attributes :id, :name, :description, :created_at, :updated_at

  belongs_to :client
  has_many :scorecards
end

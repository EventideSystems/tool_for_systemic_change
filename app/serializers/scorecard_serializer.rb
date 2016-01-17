class ScorecardSerializer < BaseSerializer
  attributes :id, :name, :description, :shared_link_id, :created_at, :updated_at

  belongs_to :client
  belongs_to :community
  belongs_to :initiatives # SMELL belongs_to? the relationship is actually has_many
  belongs_to :wicked_problem
end

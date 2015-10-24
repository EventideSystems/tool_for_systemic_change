class InitiativeSerializer < BaseSerializer
  attributes :id, :name, :description, :created_at, :updated_at

  belongs_to :scorecard
  has_many :organisations
end

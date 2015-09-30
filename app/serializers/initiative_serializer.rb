class InitiativeSerializer < BaseSerializer
  attributes :id, :name, :description

  belongs_to :scorecard
  has_many :organisations
end

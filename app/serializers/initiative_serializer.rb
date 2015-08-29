class InitiativeSerializer < BaseSerializer
  attributes :id, :name, :description

  belongs_to :wicked_problem
  has_many :organisations
end

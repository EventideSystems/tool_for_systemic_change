class InitiativeSerializer < BaseSerializer
  attributes :id, :name, :description,
             :started_at, :finished_at, :dates_confirmed,
             :created_at, :updated_at

  belongs_to :scorecard
  has_many :organisations
end

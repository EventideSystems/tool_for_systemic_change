class ScorecardInitiativeSerializer < InitiativeSerializer
  attributes :id, :name, :description,
             :started_at, :finished_at, :dates_confirmed,
             :created_at, :updated_at

  has_many :checklist_items
end

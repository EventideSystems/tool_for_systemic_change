class ScorecardInitiativeSerializer < InitiativeSerializer
  attributes :id, :name, :description, :created_at, :updated_at

  has_many :checklist_items
end

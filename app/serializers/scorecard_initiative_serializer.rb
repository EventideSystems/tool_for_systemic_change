class ScorecardInitiativeSerializer < InitiativeSerializer
  attributes :id, :name, :description

  has_many :checklist_items
end

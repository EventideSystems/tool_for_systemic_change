class ScorecardInitiativeSerializer < InitiativeSerializer
  attributes :id, :name, :description,
             :started_at, :finished_at, :dates_confirmed,
             :created_at, :updated_at,
             :contact_name,
             :contact_email,
             :contact_phone,
             :contact_website,
             :contact_position

  has_many :checklist_items
end

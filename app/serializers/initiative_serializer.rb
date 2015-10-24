class InitiativeSerializer < BaseSerializer
  attributes :id, :name, :description,
             :started_at, :finished_at, :dates_confirmed,
             :created_at, :updated_at,
             :contact_name,
             :contact_email,
             :contact_phone,
             :contact_website,
             :contact_position
  belongs_to :scorecard
  has_many :organisations
end

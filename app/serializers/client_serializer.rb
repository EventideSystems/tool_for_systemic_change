class ClientSerializer < BaseSerializer
  attributes :id, :name, :description, :created_at, :updated_at

  # SMELL Required?
  has_many :organisations
end

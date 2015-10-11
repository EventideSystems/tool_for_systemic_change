class ClientSerializer < BaseSerializer
  attributes :id, :name, :description

  # SMELL Required?
  has_many :organisations
end

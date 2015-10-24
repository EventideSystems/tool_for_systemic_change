class WickedProblemSerializer < BaseSerializer
  attributes :id, :name, :description, :created_at, :updated_at

  belongs_to :client
end

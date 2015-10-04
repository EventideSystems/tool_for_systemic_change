class WickedProblemSerializer < BaseSerializer
  attributes :id, :name, :description

  belongs_to :client
end

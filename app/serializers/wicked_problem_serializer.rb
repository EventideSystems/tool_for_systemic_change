class WickedProblemSerializer < BaseSerializer
  attributes :id, :name, :description, :created_at, :updated_at

  belongs_to :administrating_organisation
  belongs_to :community
end

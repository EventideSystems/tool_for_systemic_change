class FocusAreaGroupWithCharacteristicsSerializer < FocusAreaGroupSerializer
  attributes :id, :name, :description, :created_at, :updated_at

  has_many :focus_areas, serializer: FocusAreaWithCharacteristicsSerializer
end

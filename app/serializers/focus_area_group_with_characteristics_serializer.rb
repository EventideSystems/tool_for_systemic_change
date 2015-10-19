class FocusAreaGroupWithCharacteristicsSerializer < FocusAreaGroupSerializer
  attributes :id, :name, :description

  has_many :focus_areas, serializer: FocusAreaWithCharacteristicsSerializer
end

class FocusAreaWithCharacteristicsSerializer < FocusAreaSerializer
  has_many :characteristics, :created_at, :updated_at
end

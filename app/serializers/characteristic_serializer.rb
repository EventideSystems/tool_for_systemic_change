class CharacteristicSerializer < BaseSerializer
  attributes :id, :name, :position, :created_at, :updated_at

  belongs_to :focus_area

  has_many :video_tutorials

end


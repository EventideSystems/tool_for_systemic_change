class CharacteristicSerializer < BaseSerializer
  attributes :id, :name, :position

  belongs_to :focus_area

end


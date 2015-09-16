class CharacteristicSerializer < BaseSerializer
  attributes :id, :name

  belongs_to :focus_area

end


class FocusAreaGroupSerializer < BaseSerializer
  attributes :id, :name, :description

  has_many :focus_areas
end

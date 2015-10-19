class FocusAreaSerializer < BaseSerializer
  attributes :id, :name, :description, :position

  belongs_to :focus_area_group
end

class FocusAreaSerializer < BaseSerializer
  attributes :id, :name, :description, :focus_area_group

  belongs_to :focus_area_group
  has_many :characteristics
end

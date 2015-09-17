class FocusAreaSerializer < BaseSerializer
  attributes :id, :name, :description

  belongs_to :focus_area_group
  has_many :characteristics
end

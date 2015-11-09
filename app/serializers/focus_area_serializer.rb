class FocusAreaSerializer < BaseSerializer
  attributes :id, :name, :description, :position, :created_at, :updated_at

  belongs_to :focus_area_group
  has_many :video_tutorials
end

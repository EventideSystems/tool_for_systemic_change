# == Schema Information
#
# Table name: focus_areas
#
#  id                  :integer          not null, primary key
#  actual_color        :string
#  deleted_at          :datetime
#  description         :string
#  icon_name           :string           default("")
#  name                :string
#  planned_color       :string
#  position            :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  focus_area_group_id :integer
#
# Indexes
#
#  index_focus_areas_on_deleted_at           (deleted_at)
#  index_focus_areas_on_focus_area_group_id  (focus_area_group_id)
#  index_focus_areas_on_position             (position)
#
FactoryBot.define do
  sequence(:focus_area_position) { |n| n }
  
  factory :focus_area do
    name { FFaker::Name.name }
    focus_area_group
    position { generate(:focus_area_position) }
  end
end

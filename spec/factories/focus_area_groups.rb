FactoryBot.define do
  sequence(:focus_area_group_position) { |n| n }
  
  factory :focus_area_group do
    name { FFaker::Name.name }
    position { generate(:focus_area_group_position) }
  end
end

FactoryBot.define do
  sequence(:focus_area_position) { |n| n }
  
  factory :focus_area do
    name { FFaker::Name.name }
    focus_area_group
    position { generate(:focus_area_position) }
  end
end

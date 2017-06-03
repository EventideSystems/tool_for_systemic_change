FactoryGirl.define do
  sequence(:characteristic_position) { |n| n }
  
  factory :characteristic do
    name { FFaker::Name.name }
    focus_area
    position { generate(:characteristic_position) }
  end
end
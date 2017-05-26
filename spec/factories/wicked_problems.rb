FactoryGirl.define do
  factory :wicked_problem do
    name { FFaker::Name.name }
    account
  end
end
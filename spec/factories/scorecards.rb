FactoryGirl.define do
  factory :scorecard do
    name { FFaker::Name.name }
    account
    wicked_problem
    community
  end
end
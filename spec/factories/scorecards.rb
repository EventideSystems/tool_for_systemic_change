FactoryGirl.define do
  factory :scorecard do
    name { FFaker::Name.name }
    description { FFaker::Lorem.paragraph }
    account
    wicked_problem
    community
  end
end
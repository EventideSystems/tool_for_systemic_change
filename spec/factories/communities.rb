FactoryGirl.define do
  factory :community do
    name { FFaker::Name.name }
    account
  end
end
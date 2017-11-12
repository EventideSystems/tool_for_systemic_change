FactoryGirl.define do
  factory :organisation do
    sector
    account
    name { FFaker::Name.name }
  end
end

FactoryGirl.define do
  factory :account do
    name { FFaker::Company.name }
  end
end
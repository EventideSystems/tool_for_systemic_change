FactoryGirl.define do
  factory :client do
    name { FFaker::Company.name }
    description { FFaker::Lorem.words.join(' ') }
  end
end

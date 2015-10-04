FactoryGirl.define do
  factory :wicked_problem do
    name { FFaker::Lorem.words.join(' ') }
    description { FFaker::Lorem.words.join(' ') }
    client { create(:client) }
  end
end

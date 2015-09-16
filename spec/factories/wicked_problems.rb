FactoryGirl.define do
  factory :wicked_problem do
    name { FFaker::Lorem.words(4).join(' ') }
    description { FFaker::Lorem.words.join(' ') }
    client { create(:client) }
    community { create(:community, client: client )}
  end

end

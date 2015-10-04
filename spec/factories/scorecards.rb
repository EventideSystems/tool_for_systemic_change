FactoryGirl.define do
  factory :scorecard do
    name { FFaker::Lorem.words(4).join(' ') }
    description { FFaker::Lorem.words.join(' ') }
    client { create(:client) }
    community { create(:community, client: client )}
    wicked_problem { create(:wicked_problem, client: client )}
  end

end

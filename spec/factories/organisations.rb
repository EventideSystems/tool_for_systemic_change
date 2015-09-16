FactoryGirl.define do
  factory :organisation do
    name { FFaker::Company.name }
    description { FFaker::Lorem.words.join(' ') }
    client { create(:client) }
  end

end

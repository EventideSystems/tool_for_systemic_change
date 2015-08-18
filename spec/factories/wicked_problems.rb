FactoryGirl.define do
  factory :wicked_problem do
    name { FFaker::Lorem.words(4).join(' ') }
    description { FFaker::Lorem.words.join(' ') }
  end

end

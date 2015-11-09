FactoryGirl.define do
  factory :video_tutorial do
    name { FFaker::Lorem.words.join(' ') }
    description { FFaker::Lorem.words.join(' ') }
  end
end

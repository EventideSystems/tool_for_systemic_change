FactoryGirl.define do
  factory :initiative do
    name { FFaker::Lorem.words(4).join(' ') }
    description { FFaker::Lorem.words.join(' ') }
  end

end

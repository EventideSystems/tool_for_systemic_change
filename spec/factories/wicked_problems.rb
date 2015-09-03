FactoryGirl.define do
  factory :wicked_problem do
    name { FFaker::Lorem.words(4).join(' ') }
    description { FFaker::Lorem.words.join(' ') }
    administrating_organisation { create(:administrating_organisation) }
    community { create(:community, administrating_organisation: administrating_organisation )}
  end

end

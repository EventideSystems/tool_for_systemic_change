FactoryGirl.define do
  factory :initiative do
    scorecard
    
    name { FFaker::Name.name }
    description { FFaker::Lorem.paragraph }
    started_at { Date.today - 1 }
    finished_at { Date.today + 1 }
    dates_confirmed { true }
    contact_name { FFaker::Name.name }
    contact_email { FFaker::Internet.email }
    contact_phone { FFaker::PhoneNumberAU.phone_number }
    contact_website { FFaker::Internet.http_url }
    contact_position { FFaker::Job }
    
  end
end
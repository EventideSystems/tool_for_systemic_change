FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.email }
    name { FFaker::Name.name }
    password "example123"
    password_confirmation "example123"

    factory :admin_user do
      role :admin
    end

    factory :staff_user do
      role :staff
    end

    trait :with_admin_organisation do
      association :client, factory: :client
    end
  end
end

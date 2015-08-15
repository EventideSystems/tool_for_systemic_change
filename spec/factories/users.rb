FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.email }
    password "example123"
    password_confirmation "example123"

    factory :admin_user do
      role :admin
    end

    factory :staff_user do
      role :staff
    end

    trait :with_admin_organisation do
      association :administrating_organisation, factory: :administrating_organisation
    end
  end
end

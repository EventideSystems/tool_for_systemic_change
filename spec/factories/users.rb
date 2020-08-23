FactoryBot.define do
  # Define a basic devise user.
  factory :user do
    email { FFaker::Internet.email }
    password { 'example' }
    password_confirmation { 'example' }
    system_role { :member }
    
    transient do
      default_account { nil }
      default_account_role { nil }
    end
    
    after(:create) do |user, evaluator|
      if evaluator.default_account.present?
        account_role = evaluator.default_account_role || :member
        create(:accounts_user, user: user, account: evaluator.default_account, account_role: account_role)
      end
    end
    
    factory :admin_user do
      system_role { :admin }
    end
  end
end

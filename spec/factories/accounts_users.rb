FactoryGirl.define do
  factory :accounts_user do
    account
    user
    account_role :member
  end
end
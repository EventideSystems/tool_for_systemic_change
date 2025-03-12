# frozen_string_literal: true

Given('the {string} account has expired') do |string|
  @account = Account.find_by(name: string)
  @account.update!(expires_on: 1.day.ago)
end

Then('I will be prompted to renew my account') do
  expect(page).to have_content('Please contact your account administrator to renew your subscription.')
end

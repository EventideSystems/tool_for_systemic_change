# frozen_string_literal: true

Given('the {string} workspace has expired') do |string|
  @workspace = Workspace.find_by(name: string)
  @workspace.update!(expires_on: 1.day.ago)
end

Then('I will be prompted to renew my workspace') do
  expect(page).to have_content('Please contact your account administrator to renew your subscription.')
end

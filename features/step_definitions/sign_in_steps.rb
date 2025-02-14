# frozen_string_literal: true

Given('I already have an admin user account') do
  create(
    :user,
    system_role: :admin,
    email: 'admin@obsek.io',
    password: 'password',
    password_confirmation: 'password',
    name: 'Admin User'
  )
end

Given('an account named {string} exists') do |string|
  create(:account, name: string)
end

When('I sign in') do
  visit new_user_session_path
  fill_in('user[email]', with: 'admin@obsek.io')
  fill_in('user[password]', with: 'password')
  click_button('Sign in')
  sleep(1)
end

Then('I will be presented with the {string} home page') do |string|
  expect(page).to have_content("Welcome to the '#{string}' workspace")
end

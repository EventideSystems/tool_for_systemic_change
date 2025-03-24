# frozen_string_literal: true

Given('a workspace named {string} exists') do |string|
  create(:workspace, name: string)
end

Given('I am logged in') do
  visit new_user_session_path
  fill_in('user[email]', with: @user.email)
  fill_in('user[password]', with: @user_password)
  click_button('Sign in')
  sleep(1)
end

When('I sign in') do
  visit new_user_session_path
  fill_in('user[email]', with: @user.email)
  fill_in('user[password]', with: @user_password)
  click_button('Sign in')
  sleep(1)
end

Then('I will be presented with the {string} home page') do |string|
  expect(page).to have_content("Welcome to the '#{string}' workspace")
end

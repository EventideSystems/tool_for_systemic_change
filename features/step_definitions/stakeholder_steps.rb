# frozen_string_literal: true

When('I visit the list of stakeholders') do
  visit organisations_path
end

When('I create a new stakeholder named {string}') do |string|
  visit new_organisation_path
  fill_in('organisation[name]', with: string)
  click_button('Save')
end

Then('a stakeholder named {string} will appear in the list of stakeholders') do |string|
  visit new_organisation_path
  expect(page).to have_content(string)
end

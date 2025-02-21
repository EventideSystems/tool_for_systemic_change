# frozen_string_literal: true

Given('a stakeholder typed named {string} exists') do |string|
  @stakeholder_type = create(:stakeholder_type, name: string)
end

When('I visit the list of stakeholder types') do
  visit labels_stakeholder_types_path
end

@javascript
When('I create a new stakeholder type named {string}') do |string|
  visit labels_stakeholder_types_path
  sleep(1)
  find('a', text: 'Create Stakeholder Type').trigger('click')
  sleep(1)
  fill_in('stakeholder_type[name]', with: string)
  click_button('Save')
end

Then('the new stakeholder type will appear on the list of stakeholder types') do
  pending # Write code here that turns the phrase above into concrete actions
end

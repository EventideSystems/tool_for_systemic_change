# frozen_string_literal: true

Given('a stakeholder typed named {string} exists') do |string|
  @stakeholder_type = create(:stakeholder_type, name: string)
end

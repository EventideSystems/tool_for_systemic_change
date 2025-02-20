Feature: Stakeholder Type management

Scenario: Create stakeholder type
Given an account named "Default Account" exists
And I am an admin user for the "Default Account"
When I visit the list of stakeholder types
And I create a new stakeholder type named "New Stakeholder Type"
Then the new stakeholder type will appear on the list of stakeholder types

Feature: Stakeholder management

Scenario: Create stakeholder
Given an account named "Default Account" exists
And I am an admin user for the "Default Account"
When I visit the list of stakeholders
And I create a new stakeholder named "New Stakeholder"
Then the new stakeholder will appear on the list of stakeholders

Scenario: Create a new Stakeholder within a new Initiative


Scenario: Create a new stakeholder within an existing initiative

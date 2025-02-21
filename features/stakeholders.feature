Feature: Stakeholder management

Background:
  Given a stakeholder typed named "Business" exists
  And a stakeholder typed named "Government" exists
  And a stakeholder typed named "Community" exists

Scenario: Create stakeholder
Given an account named "Default Account" exists
And I am an admin user for the "Default Account" account
When I sign in
And I visit the list of stakeholders
And I create a new stakeholder named "New Stakeholder"
Then a stakeholder named "New Stakeholder" will appear in the list of stakeholders

Scenario: Create a new Stakeholder within a new Initiative
Given an account named "Default Account" exists
And I am an admin user for the "Default Account"
When I create a new initiative
And I create a new stakeholder named "New Stakeholder 2"
Then the new stakeholder will appear on the initiative details page
And will also appear on the list of stakeholders

Scenario: Create a new stakeholder within an existing initiative
Given an account named "Default Account" exists
And I am an admin user for the "Default Account"
And an initiative exists
When I edit that initiative
And I create a new stakeholder named "New Stakeholder 3"
Then the new stakeholder will appear on the initiative details page
And will also appear on the list of stakeholders

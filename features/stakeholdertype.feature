Feature: Stakeholder Type management

Scenario: Create stakeholder type
Given a workspace named "Default Workspace" exists
And I am an admin user for the "Default Workspace" workspace
And I am logged in
When I visit the list of stakeholder types
And I create a new stakeholder type named "New Stakeholder Type"
Then the new stakeholder type will appear on the list of stakeholder types

Feature: Subsystem Tag management

Scenario: Create a new subsystem tag
Given an account named "Default Account" exists
And I am an admin user for the "Default Account" account
When I visit the list of subsystem tags
And I create a new subsystem tag named "New Subsystem Tag"
Then the new subsystem tag will appear on the list of subsystem tags

Scenario: Create a new subsystem tag within a new initiative

Scenario: Create a new subsystem tag within an existing initiative

Feature: Subsystem Tag management

Scenario: Create a new subsystem tag
Given a workspace named "Default Workspace" exists
And I am an admin user for the "Default Workspace" workspace
When I visit the list of subsystem tags
And I create a new subsystem tag named "New Subsystem Tag"
Then the new subsystem tag will appear on the list of subsystem tags

Scenario: Create a new subsystem tag within a new initiative

Scenario: Create a new subsystem tag within an existing initiative

Feature: Sign in

Scenario: Sign in as an admin
Given I am a system admin user
And a workspace named "Default Workspace" exists
When I sign in
Then I will be presented with the "Default Workspace" home page 

Scenario: Sign in to an expired workspace
Given a workspace named "Default Workspace" exists
And the "Default Workspace" workspace has expired
And I am an admin user for the "Default Workspace" workspace
When I sign in
Then I will be presented with the "Default Workspace" home page 
And I will be prompted to renew my workspace

Scenario: Automatically sign in to first active workspace
Given a workspace named "Expired Workspace" exists
And the "Expired Workspace" workspace has expired
And a workspace named "Default Workspace" exists
And I am an admin user for the "Expired Workspace" workspace
And I am an admin user for the "Default Workspace" workspace
When I sign in
Then I will be presented with the "Default Workspace" home page 
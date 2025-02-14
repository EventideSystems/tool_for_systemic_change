Feature: Sign in

Scenario: Sign in as an admin
Given I already have an admin user account
And an account named "Default Account" exists
When I sign in
Then I will be presented with the "Default Account" home page 
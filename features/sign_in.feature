Feature: Sign in

Scenario: Sign in as an admin
Given I am a system admin user
And an account named "Default Account" exists
When I sign in
Then I will be presented with the "Default Account" home page 


Scenario: Sign in to an expired account
Given an account named "Default Account" exists
And the "Default Account" account has expired
And I am an admin user for the "Default Account" account
When I sign in
Then I will be presented with the "Default Account" home page 
And I will be prompted to renew my account

Scenario: Automatically sign in to first active account
Given an account named "Expired Account" exists
And the "Expired Account" account has expired
And an account named "Default Account" exists
And I am an admin user for the "Expired Account" account
And I am an admin user for the "Default Account" account
When I sign in
Then I will be presented with the "Default Account" home page 
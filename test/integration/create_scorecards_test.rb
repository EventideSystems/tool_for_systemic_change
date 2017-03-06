require 'test_helper'

class CreateScorecardTest < ActionDispatch::IntegrationTest

  setup do
    @account = accounts(:client)
  end
  
  test "system admin CAN create a wicked problem" do
    sign_in users(:system_admin)
    
    ApplicationController.stub_any_instance(:current_account, @account) do
      post "/scorecards",
        params: { 
          scorecard: { 
            name: "new scorecard", 
            description: "description",
            wicked_problem_name: "new wicked problem",
            wicked_problem_description: "new wicked problem description",
            community_name: "new community",
            community_description: "new community description"
          } 
        }
    end
    
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
end
require 'test_helper'

class CreatingWickedProblemsTest < ActionDispatch::IntegrationTest

  setup do
    @account = accounts(:client)
  end
  
  test "system admin CAN create a wicked problem" do
    sign_in users(:system_admin)
    
    ApplicationController.stub_any_instance(:current_account, @account) do
      post "/wicked_problems",
        params: { wicked_problem: { name: "new wicked problem", description: "description" } }
    end
    
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
  
  test "system admin CAN create a wicked problem for a specific account" do
    sign_in users(:system_admin)
    
    post "/wicked_problems",
      params: {
        wicked_problem: { 
          name: "new wicked problem", description: "description", account_id: accounts(:default).id
        } 
      }
    
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
  
  test "account admin CAN create a wicked problem for the logged in account" do
    sign_in users(:account_admin)
    
    ApplicationController.stub_any_instance(:current_account, @account) do
      post "/wicked_problems",
        params: { wicked_problem: { name: "new wicked problem", description: "description" } }
    end
    
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
  
  test "account admin CAN NOT create a wicked problem for a different (not logged in) account" do
    sign_in users(:account_admin)
    
    ApplicationController.stub_any_instance(:current_account, @account) do
      post "/wicked_problems",
        params: { 
          wicked_problem: { 
            name: "new wicked problem", description: "description" , account_id: accounts(:default).id
          } 
        }
    end
    
    assert_response :redirect
    follow_redirect!
    assert_response :redirect
  end
  
  test "account member CAN NOT create a wicked problem" do
    sign_in users(:account_member)
    
    ApplicationController.stub_any_instance(:current_account, @account) do
      post "/wicked_problems",
        params: { wicked_problem: { name: "new wicked problem", description: "description" } }
    end
    
    # SMELL This chains through a redirect to home. It probably should actually render a 403 Forbidden page
    assert_response :redirect
    follow_redirect!
    assert_response :redirect
  end
end

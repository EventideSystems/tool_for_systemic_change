require 'test_helper'

class WickedProblemsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wicked_problem_1 = wicked_problems(:wicked_problem_1)
    @wicked_problem_2 = wicked_problems(:wicked_problem_2)
    @account = accounts(:client)
  end
  
  test "should not get index if not signed in" do
    sign_out users(:system_admin)
    
    get wicked_problems_url
    assert_response :redirect
  end

  test "should get index" do
    sign_in users(:system_admin)
    get wicked_problems_url
    assert_response :success
    assert_equal(2, assigns[:wicked_problems].count)
  end
  
  test "should get index restricted to account" do
    sign_in users(:account_admin)
    ApplicationController.stub_any_instance(:current_account, @account) do
      get wicked_problems_url
      assert_response :success
      assert_equal(1, assigns[:wicked_problems].count)
    end
  end

  test "should get new" do
    sign_in users(:system_admin)
    
    get new_wicked_problem_url
    assert_response :success
  end

  test "should create wicked_problem" do
    sign_in users(:system_admin)
    
    assert_difference('WickedProblem.count') do
      post wicked_problems_url, params: { wicked_problem: { name: 'test name', description: 'test description' } }
    end

    assert_redirected_to wicked_problem_url(WickedProblem.last)
  end

  test "should show wicked_problem" do
    sign_in users(:system_admin)

    get wicked_problem_url(@wicked_problem_1)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:system_admin)
    
    get edit_wicked_problem_url(@wicked_problem_1)
    assert_response :success
  end

  test "should update wicked_problem" do
    sign_in users(:system_admin)
    
    patch wicked_problem_url(@wicked_problem_1), 
      params: { wicked_problem: { name: 'new test name', description: 'test description' }  }
    assert_redirected_to wicked_problem_url(@wicked_problem_1)
  end

  test "should destroy wicked_problem" do
    sign_in users(:system_admin)
    
    assert_difference('WickedProblem.count', -1) do
      delete wicked_problem_url(@wicked_problem_1)
    end

    assert_redirected_to wicked_problems_url
  end

end

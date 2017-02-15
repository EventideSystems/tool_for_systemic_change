require 'test_helper'

class WickedProblemsControllerTest < ActionDispatch::IntegrationTest
  
  # test 'authenticated users can GET index' do
  #   sign_in users(:system_admin)
  #
  #   get '/'
  #   assert_response :redirect
  # end
  
  setup do
    @wicked_problem = wicked_problems(:wicked_problem_1)
    @account = accounts(:client)
    
    # ApplicationController.stub_any_instance(:current_account, @account)
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

    get wicked_problem_url(@wicked_problem)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:system_admin)
    
    get edit_wicked_problem_url(@wicked_problem)
    assert_response :success
  end

  test "should update wicked_problem" do
    sign_in users(:system_admin)
    
    patch wicked_problem_url(@wicked_problem), 
      params: { wicked_problem: { name: 'new test name', description: 'test description' }  }
    assert_redirected_to wicked_problem_url(@wicked_problem)
  end

  test "should destroy wicked_problem" do
    sign_in users(:system_admin)
    
    assert_difference('WickedProblem.count', -1) do
      delete wicked_problem_url(@wicked_problem)
    end

    assert_redirected_to wicked_problems_url
  end
end

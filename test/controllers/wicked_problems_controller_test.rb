require 'test_helper'

class WickedProblemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wicked_problem = wicked_problems(:one)
  end

  test "should get index" do
    get wicked_problems_url
    assert_response :success
  end

  test "should get new" do
    get new_wicked_problem_url
    assert_response :success
  end

  test "should create wicked_problem" do
    assert_difference('WickedProblem.count') do
      post wicked_problems_url, params: { wicked_problem: {  } }
    end

    assert_redirected_to wicked_problem_url(WickedProblem.last)
  end

  test "should show wicked_problem" do
    get wicked_problem_url(@wicked_problem)
    assert_response :success
  end

  test "should get edit" do
    get edit_wicked_problem_url(@wicked_problem)
    assert_response :success
  end

  test "should update wicked_problem" do
    patch wicked_problem_url(@wicked_problem), params: { wicked_problem: {  } }
    assert_redirected_to wicked_problem_url(@wicked_problem)
  end

  test "should destroy wicked_problem" do
    assert_difference('WickedProblem.count', -1) do
      delete wicked_problem_url(@wicked_problem)
    end

    assert_redirected_to wicked_problems_url
  end
end

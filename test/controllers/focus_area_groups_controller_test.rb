require 'test_helper'

class FocusAreaGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @focus_area_group = focus_area_groups(:one)
  end

  test "should get index" do
    get focus_area_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_focus_area_group_url
    assert_response :success
  end

  test "should create focus_area_group" do
    assert_difference('FocusAreaGroup.count') do
      post focus_area_groups_url, params: { focus_area_group: {  } }
    end

    assert_redirected_to focus_area_group_url(FocusAreaGroup.last)
  end

  test "should show focus_area_group" do
    get focus_area_group_url(@focus_area_group)
    assert_response :success
  end

  test "should get edit" do
    get edit_focus_area_group_url(@focus_area_group)
    assert_response :success
  end

  test "should update focus_area_group" do
    patch focus_area_group_url(@focus_area_group), params: { focus_area_group: {  } }
    assert_redirected_to focus_area_group_url(@focus_area_group)
  end

  test "should destroy focus_area_group" do
    assert_difference('FocusAreaGroup.count', -1) do
      delete focus_area_group_url(@focus_area_group)
    end

    assert_redirected_to focus_area_groups_url
  end
end

require 'test_helper'

class FocusAreasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @focus_area = focus_areas(:one)
  end

  test "should get index" do
    get focus_areas_url
    assert_response :success
  end

  test "should get new" do
    get new_focus_area_url
    assert_response :success
  end

  test "should create focus_area" do
    assert_difference('FocusArea.count') do
      post focus_areas_url, params: { focus_area: {  } }
    end

    assert_redirected_to focus_area_url(FocusArea.last)
  end

  test "should show focus_area" do
    get focus_area_url(@focus_area)
    assert_response :success
  end

  test "should get edit" do
    get edit_focus_area_url(@focus_area)
    assert_response :success
  end

  test "should update focus_area" do
    patch focus_area_url(@focus_area), params: { focus_area: {  } }
    assert_redirected_to focus_area_url(@focus_area)
  end

  test "should destroy focus_area" do
    assert_difference('FocusArea.count', -1) do
      delete focus_area_url(@focus_area)
    end

    assert_redirected_to focus_areas_url
  end
end

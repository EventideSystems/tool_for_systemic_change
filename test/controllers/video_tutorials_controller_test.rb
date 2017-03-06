require 'test_helper'

class VideoTutorialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @video_tutorial = video_tutorials(:one)
  end

  test "should get index" do
    get video_tutorials_url
    assert_response :success
  end

  test "should get new" do
    get new_video_tutorial_url
    assert_response :success
  end

  test "should create video_tutorial" do
    assert_difference('VideoTutorial.count') do
      post video_tutorials_url, params: { video_tutorial: {  } }
    end

    assert_redirected_to video_tutorial_url(VideoTutorial.last)
  end

  test "should show video_tutorial" do
    get video_tutorial_url(@video_tutorial)
    assert_response :success
  end

  test "should get edit" do
    get edit_video_tutorial_url(@video_tutorial)
    assert_response :success
  end

  test "should update video_tutorial" do
    patch video_tutorial_url(@video_tutorial), params: { video_tutorial: {  } }
    assert_redirected_to video_tutorial_url(@video_tutorial)
  end

  test "should destroy video_tutorial" do
    assert_difference('VideoTutorial.count', -1) do
      delete video_tutorial_url(@video_tutorial)
    end

    assert_redirected_to video_tutorials_url
  end
end

require 'test_helper'

class ChecklistItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @checklist_item = checklist_items(:one)
  end

  test "should get index" do
    get checklist_items_url
    assert_response :success
  end

  test "should get new" do
    get new_checklist_item_url
    assert_response :success
  end

  test "should create checklist_item" do
    assert_difference('ChecklistItem.count') do
      post checklist_items_url, params: { checklist_item: {  } }
    end

    assert_redirected_to checklist_item_url(ChecklistItem.last)
  end

  test "should show checklist_item" do
    get checklist_item_url(@checklist_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_checklist_item_url(@checklist_item)
    assert_response :success
  end

  test "should update checklist_item" do
    patch checklist_item_url(@checklist_item), params: { checklist_item: {  } }
    assert_redirected_to checklist_item_url(@checklist_item)
  end

  test "should destroy checklist_item" do
    assert_difference('ChecklistItem.count', -1) do
      delete checklist_item_url(@checklist_item)
    end

    assert_redirected_to checklist_items_url
  end
end

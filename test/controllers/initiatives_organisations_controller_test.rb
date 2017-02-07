require 'test_helper'

class InitiativesOrganisationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @initiatives_organisation = initiatives_organisations(:one)
  end

  test "should get index" do
    get initiatives_organisations_url
    assert_response :success
  end

  test "should get new" do
    get new_initiatives_organisation_url
    assert_response :success
  end

  test "should create initiatives_organisation" do
    assert_difference('InitiativesOrganisation.count') do
      post initiatives_organisations_url, params: { initiatives_organisation: {  } }
    end

    assert_redirected_to initiatives_organisation_url(InitiativesOrganisation.last)
  end

  test "should show initiatives_organisation" do
    get initiatives_organisation_url(@initiatives_organisation)
    assert_response :success
  end

  test "should get edit" do
    get edit_initiatives_organisation_url(@initiatives_organisation)
    assert_response :success
  end

  test "should update initiatives_organisation" do
    patch initiatives_organisation_url(@initiatives_organisation), params: { initiatives_organisation: {  } }
    assert_redirected_to initiatives_organisation_url(@initiatives_organisation)
  end

  test "should destroy initiatives_organisation" do
    assert_difference('InitiativesOrganisation.count', -1) do
      delete initiatives_organisation_url(@initiatives_organisation)
    end

    assert_redirected_to initiatives_organisations_url
  end
end

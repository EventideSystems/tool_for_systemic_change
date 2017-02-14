require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'authenticated users can GET index' do
    sign_in users(:system_admin)

    get '/'
    assert_response :redirect
  end

end

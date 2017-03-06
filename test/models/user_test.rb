require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
  
  test "default account is first with admin access" do
    user = users(:account_admin)
    
    assert_equal(accounts(:client), user.default_account)
  end
end
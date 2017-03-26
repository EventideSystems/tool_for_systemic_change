require 'rails_helper'

RSpec.describe "accounts page", :type => :request do
  it "displays the user's username after successful login" do
    @user = FactoryGirl.create(:user)
    
    sign_in_as_a_valid_user
  end
end
# frozen_string_literal: true

# This support package contains modules for authenticaiting
# devise users for request specs.

# This module authenticates users for request specs.#
# module ValidUserRequestHelper
#   # Define a method which signs in as a valid user.
#   def sign_in_as_a_valid_user
#     # ASk factory girl to generate a valid user for us.
#     @user ||= FactoryBot.create :user
#
#     # We action the login request using the parameters before we begin.
#     # The login requests will match these to the user we just created in the factory, and authenticate us.
#     post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
#   end
# end
#
# # Configure these to modules as helpers in the appropriate tests.
# RSpec.configure do |config|
#   # Include the help for the request specs.
#   config.include ValidUserRequestHelper, :type => :request
# end

module ControllerMacros
  def login_admin
    before do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      sign_in FactoryBot.create(:admin) # Using factory girl as an example
    end
  end

  def login_user(user = nil)
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      user ||= FactoryBot.create(:user)
      # user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in user
    end
  end
end

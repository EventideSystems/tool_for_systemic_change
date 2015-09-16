require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Profiles", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"

  let(:client) { create(:client) }
  let(:user) { create(:user, client: client) }
  let(:admin) { create(:admin_user, client: client) }
  let(:staff) { create(:staff_user) }

  describe "GET /profile" do

    specify "user profile" do
      sign_in(user)
      get profile_path
      profile = JSON.parse(response.body)['data']['attributes']

      expect(response).to have_http_status(200)

      expect(profile["userEmail"]).to eq(user.email)
      expect(profile["userRole"]).to eq(user.role)
      expect(profile["userName"]).to eq(user.name)
      expect(profile["clientName"]).to eq(client.name)
    end

    specify "admin profile" do
      sign_in(admin)
      get profile_path
      profile = JSON.parse(response.body)['data']['attributes']

      expect(response).to have_http_status(200)

      expect(profile["userEmail"]).to eq(admin.email)
      expect(profile["userRole"]).to eq(admin.role)
      expect(profile["userName"]).to eq(admin.name)
      expect(profile["clientName"]).to eq(client.name)
    end

    specify "staff profile" do
      sign_in(staff)
      get profile_path
      profile = JSON.parse(response.body)['data']['attributes']

      expect(response).to have_http_status(200)

      expect(profile["userEmail"]).to eq(staff.email)
      expect(profile["userRole"]).to eq(staff.role)
      expect(profile["userName"]).to eq(staff.name)
      expect(profile["clientName"]).to eq('')
    end
  end
end

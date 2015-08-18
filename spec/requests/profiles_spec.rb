require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Profiles", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"

  let(:administrating_organisation) { create(:administrating_organisation) }
  let(:user) { create(:user, administrating_organisation: administrating_organisation) }
  let(:admin) { create(:admin_user, administrating_organisation: administrating_organisation) }
  let(:staff) { create(:staff_user) }

  describe "GET /profile" do

    specify "user profile" do
      sign_in(user)
      get profile_path
      profile = JSON.parse(response.body)['data']['attributes']

      expect(response).to have_http_status(200)

      expect(profile["user_email"]).to eq(user.email)
      expect(profile["user_role"]).to eq(user.role)
      expect(profile["user_name"]).to eq(user.name)
      expect(profile["administrating_organisation_name"]).to eq(administrating_organisation.name)
    end

    specify "admin profile" do
      sign_in(admin)
      get profile_path
      profile = JSON.parse(response.body)['data']['attributes']

      expect(response).to have_http_status(200)

      expect(profile["user_email"]).to eq(admin.email)
      expect(profile["user_role"]).to eq(admin.role)
      expect(profile["user_name"]).to eq(admin.name)
      expect(profile["administrating_organisation_name"]).to eq(administrating_organisation.name)
    end

    specify "staff profile" do
      sign_in(staff)
      get profile_path
      profile = JSON.parse(response.body)['data']['attributes']

      expect(response).to have_http_status(200)

      expect(profile["user_email"]).to eq(staff.email)
      expect(profile["user_role"]).to eq(staff.role)
      expect(profile["user_name"]).to eq(staff.name)
      expect(profile["administrating_organisation_name"]).to eq('')
    end
  end
end

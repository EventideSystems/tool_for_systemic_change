require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Users", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "GET /users" do

    specify 'all fields returned' do
      sign_in(user)
      sign_in(staff)
      get users_path

      organisation_data = JSON.parse(response.body)['data'].first

      expect(organisation_data['id']).to eq(user.id.to_s)
      expect(organisation_data['attributes']['name']).to eq(user.name)
      expect(organisation_data['attributes']['role']).to eq(user.role)
      expect(DateTime.parse(organisation_data['attributes']['createdAt']).to_s(:db))
        .to eq(user.created_at.to_s(:db))
      expect(DateTime.parse(organisation_data['attributes']['updatedAt']).to_s(:db))
        .to eq(user.updated_at.to_s(:db))
      expect(DateTime.parse(organisation_data['attributes']['createdAt']).to_s(:db))
        .to eq(user.created_at.to_s(:db))

      relationships_data = organisation_data['relationships']

      expect(relationships_data['administratingOrganisation']['data']['id'])
        .to eq(user.administrating_organisation.id.to_s)
    end

    describe "restrict access by role" do
      specify "user profile" do
        sign_in(user)
        get users_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "admin profile" do
        sign_in(admin)
        get users_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(2)
      end

      specify "staff profile" do
        sign_in(staff)
        get users_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(3)
      end
    end
  end
end

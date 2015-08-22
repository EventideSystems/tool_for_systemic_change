require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Organisations", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  let!(:organisation) { create(:organisation,
    administrating_organisation: administrating_organisation)}

  let!(:other_organisation) { create(:organisation,
    administrating_organisation: other_administrating_organisation)}

  describe "GET /organisations" do

    specify 'all fields returned' do
      sign_in(staff)
      get organisations_path

      organisation_data = JSON.parse(response.body)['data'].first

      puts organisation_data.inspect

      expect(organisation_data['id']).to eq(organisation.id.to_s)
      expect(organisation_data['attributes']['name']).to eq(organisation.name)
      expect(organisation_data['attributes']['description']).to eq(organisation.description)

      relationships_data = organisation_data['relationships']

      expect(relationships_data['administrating_organisation']['data']['id'])
        .to eq(administrating_organisation.id.to_s)
    end

    describe "restrict access by role" do
      specify "user profile" do
        sign_in(user)
        get organisations_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "admin profile" do
        sign_in(admin)
        get organisations_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "staff profile" do
        sign_in(staff)
        get organisations_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(2)
      end
    end
  end

  describe "GET /organisations/:id" do

    describe "restrict access by role" do
      specify "user - accessible record" do
        sign_in(user)
        get organisation_path(organisation)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(organisation.id.to_s)
      end

      specify "user - inaccessible record" do
        sign_in(user)
        get organisation_path(other_organisation)

        expect(response).to have_http_status(403)
      end

      specify "admin - accessible record" do
        sign_in(admin)
        get organisation_path(organisation)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(organisation.id.to_s)
      end

      specify "admin - inaccessible record" do
        sign_in(user)
        get organisation_path(other_organisation)

        expect(response).to have_http_status(403)
      end

      specify "staff - all records" do
        sign_in(staff)
        get organisation_path(organisation)

        expect(response).to have_http_status(200)

        get organisation_path(organisation)

        expect(response).to have_http_status(200)
      end
    end

  end

  describe "POST /organisations" do
    let(:organisation_name) { FFaker::Lorem.words(4).join(' ') }
    let(:organisation_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'organisations',
        attributes: {
          name: organisation_name,
          description: organisation_description,
        },
        relationships: {
          community: { data: { id: community.id } },
          administrating_organisation: { data: { id: administrating_organisation.id } }
        }
      }
    }

    specify "posting as admin" do
      sign_in(admin)
      post '/organisations', data: data_attributes
      new_organisation = Organisation.last

      expect(response).to have_http_status(201)
      expect(new_organisation.name).to eq(organisation_name)
      expect(new_organisation.description).to eq(organisation_description)
      expect(new_organisation.administrating_organisation).to eq(administrating_organisation)
    end

    specify "posting as admin - without administrating organisation id" # TODO
  end

  describe "PUT /organisations" do
    let(:organisation_new_name) { FFaker::Lorem.words(4).join(' ') }
    let(:organisation_new_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'organisations',
        attributes: {
          name: organisation_new_name,
          description: organisation_new_description,
        },
        relationships: {
          community: { data: { id: community.id } },
          administrating_organisation: { data: { id: administrating_organisation.id } }
        }
      }
    }

    specify "updating as admin" do
      sign_in(admin)
      put "/organisations/#{organisation.id}", data: data_attributes
      organisation.reload

      expect(response).to have_http_status(200)
      expect(organisation.name).to eq(organisation_new_name)
      expect(organisation.description).to eq(organisation_new_description)
    end
  end
end

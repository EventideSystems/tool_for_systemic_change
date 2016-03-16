require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Organisations", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "GET /organisations" do

    specify 'all fields returned' do
      sign_in(staff)
      get organisations_path

      organisation_data = JSON.parse(response.body)['data'].first

      expect(organisation_data['id']).to eq(organisation.id.to_s)
      expect(organisation_data['attributes']['name']).to eq(organisation.name)
      expect(organisation_data['attributes']['description']).to eq(organisation.description)
      expect(Time.parse(organisation_data['attributes']['createdAt']).utc).
        to be_within(0.01).of(organisation.created_at.utc)

      relationships_data = organisation_data['relationships']

      expect(relationships_data['client']['data']['id'])
        .to eq(client.id.to_s)
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
        expect(JSON.parse(response.body)['data'].count).to be(1)
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

      specify "staff - inaccessible record before client context switch" do
        sign_in(staff)
        put current_client_path, id: community.client.id

        get organisation_path(other_organisation)

        expect(response).to have_http_status(403)
      end

      specify "staff - accessible record after client context switch" do
        sign_in(staff)
        put current_client_path, id: other_community.client.id

        get organisation_path(other_organisation)

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
          :'client' => { data: { id: client.id } }
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
      expect(new_organisation.client).to eq(client)
    end

    specify "posting as admin - without client id" do
      data_attributes.delete(:relationships)

      sign_in(admin)
      post '/organisations', data: data_attributes
      new_organisation = Organisation.last

      expect(response).to have_http_status(201)
      expect(new_organisation.name).to eq(organisation_name)
      expect(new_organisation.description).to eq(organisation_description)
      expect(new_organisation.client).to eq(client)
    end
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
          :'client' => { data: { id: client.id } }
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

  describe "DELETE /organisations/:id" do

    let!(:initiative) do
      create(:initiative,
             scorecard: scorecard,
             organisations: [organisation])
    end

    specify "cannot delete an organisation with related initiatives" do
      sign_in(admin)
      delete "/organisations/#{organisation.id}"

      expect(response).to have_http_status(403)
      expect(JSON.parse(response.body)["errors"]).
        to eq("Cannot delete record because of dependent Initiatives")
    end

    specify "can delete an organisation once related initiatives are removed" do
      Bullet.enable = false
      sign_in(admin)
      initiative.destroy
      delete "/organisations/#{organisation.id}"
      Bullet.enable = true

      puts response.body.inspect
      expect(response).to have_http_status(204)
    end
  end
end

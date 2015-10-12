require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Clients", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "GET /clients" do

    specify 'all fields returned' do
      sign_in(staff)

      get clients_path

      client_data = JSON.parse(response.body)['data'].first

      expect(client_data['id']).to eq(client.id.to_s)
      expect(client_data['attributes']['name']).to eq(client.name)
      expect(client_data['attributes']['description']).to eq(client.description)
    end

    describe "restrict access by role" do
      specify "user profile" do
        sign_in(user)
        get clients_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "admin profile" do
        sign_in(admin)
        get clients_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "staff profile" do
        sign_in(staff)
        get clients_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(2)
      end
    end
  end

  describe "GET /clients/:id" do

    describe "restrict access by role" do
      specify "user - accessible record" do
        sign_in(user)
        get client_path(client)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(client.id.to_s)
      end

      specify "user - inaccessible record" do
        sign_in(user)
        get client_path(other_client)

        expect(response).to have_http_status(403)
      end

      specify "admin - accessible record" do
        sign_in(admin)
        get client_path(client)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(client.id.to_s)
      end

      specify "admin - inaccessible record" do
        sign_in(user)
        get client_path(other_client)

        expect(response).to have_http_status(403)
      end

      specify "staff - all records" do
        sign_in(staff)
        get client_path(client)

        expect(response).to have_http_status(200)

        get client_path(client)

        expect(response).to have_http_status(200)
      end
    end

  end

  describe "POST /clients" do
    let(:client_name) { FFaker::Lorem.words(4).join(' ') }
    let(:client_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'clients',
        attributes: {
          name: client_name,
          description: client_description,
        }
      }
    }

    specify "posting as staff user" do
      sign_in(staff)
      post '/clients', data: data_attributes

      expect(response).to have_http_status(201)

      new_client = Client.last
      expect(new_client.name).to eq(client_name)
      expect(new_client.description).to eq(client_description)
    end

    specify "posting as admin - access denied" do
      sign_in(admin)
      post '/clients', data: data_attributes

      expect(response).to have_http_status(403)
    end

    specify "posting as user - access denied" do
      sign_in(user)
      post '/clients', data: data_attributes

      expect(response).to have_http_status(403)
    end
  end

  describe "PUT /clients/:id" do
    let(:client_new_name) { FFaker::Lorem.words(4).join(' ') }
    let(:client_new_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'clients',
        attributes: {
          name: client_new_name,
          description: client_new_description
        }
      }
    }

    specify "updating as staff" do
      sign_in(staff)
      put "/clients/#{client.id}", data: data_attributes
      client.reload

      expect(response).to have_http_status(200)
      expect(client.name).to eq(client_new_name)
      expect(client.description).to eq(client_new_description)
    end
  end

end

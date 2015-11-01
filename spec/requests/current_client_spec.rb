require "rails_helper"
require "shared_contexts"

RSpec.describe "Current Client", type: :request do
  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "GET /current_client" do
    specify "return User#client for admin" do
      sign_in(admin)
      get current_client_path
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["data"]["id"]).
        to eq(admin.client.id.to_s)
    end

    specify "return User#client for user" do
      sign_in(user)
      get current_client_path
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["data"]["id"]).
        to eq(user.client.id.to_s)
    end

    specify "return Client#first for staff" do
      sign_in(staff)
      get current_client_path
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["data"]["id"]).
        to eq(Client.first.id.to_s)
    end
  end

  describe "PUT /clients/current" do
    specify "update current client for staff" do
      sign_in(staff)
      get current_client_path
      expect(JSON.parse(response.body)["data"]["id"]).
        to_not eq(other_client.id.to_s)

      put current_client_path, id: other_client.id
      expect(response).to have_http_status(200)
      get current_client_path
      expect(JSON.parse(response.body)["data"]["id"]).
        to eq(other_client.id.to_s)
    end
  end
end

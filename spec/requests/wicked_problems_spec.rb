require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Wicked Problems", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "GET /wicked_problems" do

    specify 'all fields returned' do
      sign_in(staff)
      get wicked_problems_path

      wicked_problem_data = JSON.parse(response.body)['data'].first

      expect(wicked_problem_data['id']).to eq(wicked_problem.id.to_s)
      expect(wicked_problem_data['attributes']['name']).to eq(wicked_problem.name)
      expect(wicked_problem_data['attributes']['description']).to eq(wicked_problem.description)
      expect(Time.parse(wicked_problem_data['attributes']['createdAt']).utc).
        to be_within(0.01).of(wicked_problem.created_at.utc)

      relationships_data = wicked_problem_data['relationships']

      expect(relationships_data['client']['data']['id'])
        .to eq(client.id.to_s)
    end

    describe "restrict access by role" do
      specify "user profile" do
        sign_in(user)
        get wicked_problems_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "admin profile" do
        sign_in(admin)
        get wicked_problems_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "staff profile" do
        sign_in(staff)
        get wicked_problems_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end
    end
  end

  describe "GET /wicked_problems/:id" do

    describe "restrict access by role" do
      specify "user - accessible record" do
        sign_in(user)
        get wicked_problem_path(wicked_problem)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(wicked_problem.id.to_s)
      end

      specify "user - inaccessible record" do
        sign_in(user)
        get wicked_problem_path(other_wicked_problem)

        expect(response).to have_http_status(403)
      end

      specify "admin - accessible record" do
        sign_in(admin)
        get wicked_problem_path(wicked_problem)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(wicked_problem.id.to_s)
      end

      specify "admin - inaccessible record" do
        sign_in(user)
        get wicked_problem_path(other_wicked_problem)

        expect(response).to have_http_status(403)
      end

      specify "staff - inaccessible record before client context switch" do
        sign_in(staff)
        put current_client_path, id: community.client.id
        get wicked_problem_path(other_wicked_problem)

        expect(response).to have_http_status(403)
      end

      specify "staff - accessible record after client context switch" do
        sign_in(staff)
        put current_client_path, id: other_community.client.id

        get wicked_problem_path(other_wicked_problem)

        expect(response).to have_http_status(200)
      end
    end

  end

  describe "POST /wicked_problems" do
    let(:wicked_problem_name) { FFaker::Lorem.words(4).join(' ') }
    let(:wicked_problem_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'wicked_problems',
        attributes: {
          name: wicked_problem_name,
          description: wicked_problem_description,
        },
        relationships: {
          :'client' => { data: { id: client.id } }
        }
      }
    }

    specify "posting as admin" do
      sign_in(admin)
      post '/wicked_problems', data: data_attributes
      new_wicked_problem = WickedProblem.last

      expect(response).to have_http_status(201)
      expect(new_wicked_problem.name).to eq(wicked_problem_name)
      expect(new_wicked_problem.description).to eq(wicked_problem_description)
      expect(new_wicked_problem.client).to eq(client)
    end

    specify "posting as admin - without client id" do
      data_attributes.delete(:relationships)

      sign_in(admin)
      post '/wicked_problems', data: data_attributes
      new_wicked_problem = WickedProblem.last

      expect(response).to have_http_status(201)
      expect(new_wicked_problem.name).to eq(wicked_problem_name)
      expect(new_wicked_problem.description).to eq(wicked_problem_description)
      expect(new_wicked_problem.client).to eq(client)
    end
  end

  describe "PUT /wicked_problems" do
    let(:wicked_problem_new_name) { FFaker::Lorem.words(4).join(' ') }
    let(:wicked_problem_new_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'wicked_problems',
        attributes: {
          name: wicked_problem_new_name,
          description: wicked_problem_new_description,
        },
        relationships: {
          community: { data: { id: community.id } },
          :'client' => { data: { id: client.id } }
        }
      }
    }

    specify "updating as admin" do
      sign_in(admin)
      put "/wicked_problems/#{wicked_problem.id}", data: data_attributes
      wicked_problem.reload

      expect(response).to have_http_status(200)
      expect(wicked_problem.name).to eq(wicked_problem_new_name)
      expect(wicked_problem.description).to eq(wicked_problem_new_description)
    end
  end
end

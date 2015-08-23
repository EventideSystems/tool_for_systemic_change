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

      relationships_data = wicked_problem_data['relationships']

      expect(relationships_data['administratingOrganisation']['data']['id'])
        .to eq(administrating_organisation.id.to_s)

      expect(relationships_data['community']['data']['id'])
        .to eq(community.id.to_s)
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
        expect(JSON.parse(response.body)['data'].count).to be(2)
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

      specify "staff - all records" do
        sign_in(staff)
        get wicked_problem_path(wicked_problem)

        expect(response).to have_http_status(200)

        get wicked_problem_path(wicked_problem)

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
          community: { data: { id: community.id } },
          administrating_organisation: { data: { id: administrating_organisation.id } }
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
      expect(new_wicked_problem.community).to eq(community)
      expect(new_wicked_problem.administrating_organisation).to eq(administrating_organisation)
    end

    specify "posting as admin - without administrating organisation id" do
      data_attributes[:relationships].delete(:administrating_organisation)

      sign_in(admin)
      post '/wicked_problems', data: data_attributes
      new_wicked_problem = WickedProblem.last

      expect(response).to have_http_status(201)
      expect(new_wicked_problem.name).to eq(wicked_problem_name)
      expect(new_wicked_problem.description).to eq(wicked_problem_description)
      expect(new_wicked_problem.community).to eq(community)
      expect(new_wicked_problem.administrating_organisation).to eq(administrating_organisation)
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
          administrating_organisation: { data: { id: administrating_organisation.id } }
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

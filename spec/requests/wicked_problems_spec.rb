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
      expect do
        post '/wicked_problems', data: data_attributes
      end.to  change{WickedProblem.count}.by(1)

      expect(response).to have_http_status(201)

      new_wicked_problem = WickedProblem.last
      expect(new_wicked_problem.name).to eq(wicked_problem_name)
      expect(new_wicked_problem.description).to eq(wicked_problem_description)
      expect(new_wicked_problem.community).to eq(community)
      expect(new_wicked_problem.administrating_organisation).to eq(administrating_organisation)
    end

    describe "creating compound records" do

      let(:data_attributes) {
        {
          type: 'wicked_problems',
          attributes: {
            name: FFaker::Lorem.words(4).join(' '),
            description: FFaker::Lorem.words(10).join(' '),
          },
          relationships: {
            administrating_organisation: { data: { id: administrating_organisation.id } }
          }
        }
      }

      specify "posting as admin - creating new community" do

        included_attributes = [{
          type: 'communities',
          attributes: {
            name: FFaker::Lorem.words(4).join(' '),
            description: FFaker::Lorem.words(10).join(' '),
          },
          relationships: {
            administrating_organisation: { data: { id: administrating_organisation.id } }
          }
        }]

        sign_in(admin)

        expect do
          post '/wicked_problems', data: data_attributes, included: included_attributes
        end.to change{ Community.count }.by(1)

        expect(response).to have_http_status(201)

        new_community = Community.last
        expect(new_community.name).to eq(included_attributes.first[:attributes][:name])
        expect(new_community.description).to eq(included_attributes.first[:attributes][:description])
        expect(new_community.administrating_organisation).to eq(administrating_organisation)

        wicked_problem = WickedProblem.last
        expect(wicked_problem.community).to eq(new_community)
      end

      specify "posting as admin - creating new initiatives" do

        included_attributes = [
          {
            type: 'initiatives',
            attributes: {
              name: FFaker::Lorem.words(4).join(' '),
              description: FFaker::Lorem.words(10).join(' ')
            }
          },
          {
            type: 'initiatives',
            attributes: {
              name: FFaker::Lorem.words(4).join(' '),
              description: FFaker::Lorem.words(10).join(' ')
            }
          }
        ]

        data_attributes[:relationships][:community] = { data: { id: community.id } }

        sign_in(admin)


        expect do
          post '/wicked_problems', data: data_attributes, included: included_attributes
        end.to change{ Initiative.count }.by(2)

        expect(response).to have_http_status(201)

        wicked_problem = WickedProblem.last

        new_initiative = wicked_problem.initiatives.first
        expect(new_initiative.name).to eq(included_attributes.first[:attributes][:name])
        expect(new_initiative.description).to eq(included_attributes.first[:attributes][:description])

        new_initiative = wicked_problem.initiatives.second
        expect(new_initiative.name).to eq(included_attributes.second[:attributes][:name])
        expect(new_initiative.description).to eq(included_attributes.second[:attributes][:description])
      end

    end
  end

  describe "PUT /wicked_problems" do
    let(:data_attributes) {
      {
        type: 'wicked_problems',
        attributes: {
          name: FFaker::Lorem.words(4).join(' '),
          description: FFaker::Lorem.words(10).join(' '),
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
      expect(wicked_problem.name).to eq(data_attributes[:attributes][:name])
      expect(wicked_problem.description).to eq(data_attributes[:attributes][:description])
    end

    specify "updating as admin - change community" do
      wicked_problem_old_name = wicked_problem.name
      wicked_problem_old_description = wicked_problem.description
      wicked_problem_old_administrating_organisation_id = wicked_problem.administrating_organisation_id

      new_community = create(:community, administrating_organisation: administrating_organisation)

      sign_in(admin)
      data_attributes = {
        type: 'wicked_problems',
        relationships: {
          community: { data: { id: new_community.id } }
        }
      }

      put "/wicked_problems/#{wicked_problem.id}", data: data_attributes
      wicked_problem.reload

      expect(response).to have_http_status(200)
      expect(wicked_problem.name).to eq(wicked_problem_old_name)
      expect(wicked_problem.description).to eq(wicked_problem_old_description)
      expect(wicked_problem.administrating_organisation.id).to eq(wicked_problem_old_administrating_organisation_id)
      expect(wicked_problem.community.id).to eq(new_community.id)
    end
  end
end

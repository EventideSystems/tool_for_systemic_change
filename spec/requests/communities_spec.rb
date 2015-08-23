require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Communities", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "GET /communities" do

    specify 'all fields returned' do
      sign_in(staff)
      get communities_path

      community_data = JSON.parse(response.body)['data'].first

      expect(community_data['id']).to eq(community.id.to_s)
      expect(community_data['attributes']['name']).to eq(community.name)
      expect(community_data['attributes']['description']).to eq(community.description)

      relationships_data = community_data['relationships']

      expect(relationships_data['administrating_organisation']['data']['id'])
        .to eq(administrating_organisation.id.to_s)

      expect(relationships_data['wicked_problems']['data'].first['id'])
        .to eq(wicked_problem.id.to_s)
    end

    describe "restrict access by role" do
      specify "user profile" do
        sign_in(user)
        get communities_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "admin profile" do
        sign_in(admin)
        get communities_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "staff profile" do
        sign_in(staff)
        get communities_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(2)
      end
    end
  end

  describe "GET /communities/:id" do

    describe "restrict access by role" do
      specify "user - accessible record" do
        sign_in(user)
        get community_path(community)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(community.id.to_s)
      end

      specify "user - inaccessible record" do
        sign_in(user)
        get community_path(other_community)

        expect(response).to have_http_status(403)
      end

      specify "admin - accessible record" do
        sign_in(admin)
        get community_path(community)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(community.id.to_s)
      end

      specify "admin - inaccessible record" do
        sign_in(user)
        get community_path(other_community)

        expect(response).to have_http_status(403)
      end

      specify "staff - all records" do
        sign_in(staff)
        get community_path(community)

        expect(response).to have_http_status(200)

        get community_path(community)

        expect(response).to have_http_status(200)
      end
    end

  end

  describe "POST /communities" do
    let(:community_name) { FFaker::Lorem.words(4).join(' ') }
    let(:community_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'communities',
        attributes: {
          name: community_name,
          description: community_description,
        },
        # SMELL Not supporting wicked_problems relationship at this point, if
        # we do at all.
        relationships: {
          administrating_organisation: { data: { id: administrating_organisation.id } }
        }
      }
    }

    specify "posting as admin" do
      sign_in(admin)
      post '/communities', data: data_attributes

      expect(response).to have_http_status(201)

      new_community = Community.last
      expect(new_community.name).to eq(community_name)
      expect(new_community.description).to eq(community_description)
      expect(new_community.administrating_organisation).to eq(administrating_organisation)
    end

    specify "posting as admin - without administrating organisation id" do
      data_attributes.delete(:relationships)

      sign_in(admin)
      post '/communities', data: data_attributes

      expect(response).to have_http_status(201)

      new_community = Community.last
      expect(new_community.name).to eq(community_name)
      expect(new_community.description).to eq(community_description)
      expect(new_community.administrating_organisation).to eq(administrating_organisation)
    end
  end

  describe "PUT /communities/:id" do
    let(:community_new_name) { FFaker::Lorem.words(4).join(' ') }
    let(:community_new_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'communities',
        attributes: {
          name: community_new_name,
          description: community_new_description,
        },
        relationships: {
          administrating_organisation: { data: { id: administrating_organisation.id } }
        }
      }
    }

    specify "updating as admin" do
      sign_in(admin)
      put "/communities/#{community.id}", data: data_attributes
      community.reload

      expect(response).to have_http_status(200)
      expect(community.name).to eq(community_new_name)
      expect(community.description).to eq(community_new_description)
    end
  end
end

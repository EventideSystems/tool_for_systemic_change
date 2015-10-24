require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Scorecards", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "GET /scorecards" do

    specify 'all fields returned' do
      scorecard.initiatives << create(:initiative)
      scorecard.initiatives.first.organisations << organisation

      sign_in(staff)

      get scorecards_path

      scorecard_data = JSON.parse(response.body)['data'].first
      relationships_data = scorecard_data['relationships']
      include_data = JSON.parse(response.body)['included'].first

      expect(scorecard_data['id']).to eq(scorecard.id.to_s)
      expect(scorecard_data['attributes']['name']).to eq(scorecard.name)
      expect(scorecard_data['attributes']['description']).to eq(scorecard.description)
      expect(Time.parse(scorecard_data['attributes']['createdAt']).utc).
        to be_within(0.01).of(scorecard.created_at.utc)

      relationships_data = scorecard_data['relationships']

      expect(relationships_data['client']['data']['id'])
        .to eq(client.id.to_s)

      expect(relationships_data['community']['data']['id'])
        .to eq(community.id.to_s)

      expect(relationships_data['wickedProblem']['data']['id'])
        .to eq(wicked_problem.id.to_s)

      expect(relationships_data['initiatives']['data'].count).to eq(1)

      expect(include_data['relationships']['organisations']['data'].first['id'].to_i).to eq(organisation.id)
    end

    describe "restrict access by role" do
      specify "user profile" do
        sign_in(user)
        get scorecards_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "admin profile" do
        sign_in(admin)
        get scorecards_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "staff profile" do
        sign_in(staff)
        get scorecards_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(2)
      end
    end
  end

  describe "GET /scorecards/:id" do

    describe "restrict access by role" do
      specify "user - accessible record" do
        sign_in(user)
        get scorecard_path(scorecard)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(scorecard.id.to_s)
      end

      specify "user - inaccessible record" do
        sign_in(user)
        get scorecard_path(other_scorecard)

        expect(response).to have_http_status(403)
      end

      specify "admin - accessible record" do
        sign_in(admin)
        get scorecard_path(scorecard)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(scorecard.id.to_s)
      end

      specify "admin - inaccessible record" do
        sign_in(user)
        get scorecard_path(other_scorecard)

        expect(response).to have_http_status(403)
      end

      specify "staff - all records" do
        sign_in(staff)
        get scorecard_path(scorecard)

        expect(response).to have_http_status(200)

        get scorecard_path(scorecard)

        expect(response).to have_http_status(200)
      end
    end

  end

  describe "POST /scorecards" do
    let(:scorecard_name) { FFaker::Lorem.words(4).join(' ') }
    let(:scorecard_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'scorecards',
        attributes: {
          name: scorecard_name,
          description: scorecard_description,
        },
        relationships: {
          community: { data: { id: community.id } },
          client: { data: { id: client.id } },
          wicked_problem: { data: { id: wicked_problem.id } }
        }
      }
    }

    specify "posting as admin" do
      sign_in(admin)
      post '/scorecards', data: data_attributes
      new_scorecard = Scorecard.last

      expect(response).to have_http_status(201)
      expect(new_scorecard.name).to eq(scorecard_name)
      expect(new_scorecard.description).to eq(scorecard_description)
      expect(new_scorecard.community).to eq(community)
      expect(new_scorecard.client).to eq(client)
      expect(new_scorecard.wicked_problem).to eq(wicked_problem)
    end

    specify "posting as admin - without administrating organisation id" do
      data_attributes[:relationships].delete(:client)

      sign_in(admin)
      expect do
        post '/scorecards', data: data_attributes
      end.to  change{Scorecard.count}.by(1)

      expect(response).to have_http_status(201)

      new_scorecard = Scorecard.last
      expect(new_scorecard.name).to eq(scorecard_name)
      expect(new_scorecard.description).to eq(scorecard_description)
      expect(new_scorecard.community).to eq(community)
      expect(new_scorecard.client).to eq(client)
      expect(new_scorecard.wicked_problem).to eq(wicked_problem)
    end

    describe "creating compound records" do

      let(:data_attributes) {
        {
          type: 'scorecards',
          attributes: {
            name: FFaker::Lorem.words(4).join(' '),
            description: FFaker::Lorem.words(10).join(' '),
          },
          relationships: {
            client: { data: { id: client.id } },
            wicked_problem: { data: { id: wicked_problem.id } }
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
            client: { data: { id: client.id } }
          }
        }]

        sign_in(admin)

        expect do
          post '/scorecards', data: data_attributes, included: included_attributes
        end.to change{ Community.count }.by(1)

        expect(response).to have_http_status(201)

        new_community = Community.last
        expect(new_community.name).to eq(included_attributes.first[:attributes][:name])
        expect(new_community.description).to eq(included_attributes.first[:attributes][:description])
        expect(new_community.client).to eq(client)

        scorecard = Scorecard.last
        expect(scorecard.community).to eq(new_community)
      end

      specify "posting as admin - creating new initiatives" do

        second_organisation =  create(:organisation,
          client: client)

        included_attributes = [
          {
            type: 'initiatives',
            attributes: {
              name: FFaker::Lorem.words(4).join(' '),
              description: FFaker::Lorem.words(10).join(' ')
            },
            relationships: {
              organisations: { data: [
                {id: organisation.id }
              ] }
            }
          },
          {
            type: 'initiatives',
            attributes: {
              name: FFaker::Lorem.words(4).join(' '),
              description: FFaker::Lorem.words(10).join(' ')
            },
            relationships: {
              organisations: { data: [
                {id: organisation.id },
                {id: second_organisation.id }
              ] }
            }

          }
        ]

        data_attributes[:relationships][:community] = { data: { id: community.id } }

        sign_in(admin)

        expect do
          post '/scorecards', data: data_attributes, included: included_attributes
        end.to change{ Initiative.count }.by(2)

        expect(response).to have_http_status(201)

        scorecard = Scorecard.last

        new_initiative = scorecard.initiatives.first
        expect(new_initiative.name).to eq(included_attributes.first[:attributes][:name])
        expect(new_initiative.description).to eq(included_attributes.first[:attributes][:description])
        expect(new_initiative.organisations.count).to eq(1)

        new_initiative = scorecard.initiatives.second
        expect(new_initiative.name).to eq(included_attributes.second[:attributes][:name])
        expect(new_initiative.description).to eq(included_attributes.second[:attributes][:description])
        expect(new_initiative.organisations.count).to eq(2)
      end

      specify "posting as admin - creating new wicked problem" do

        data_attributes = {
          type: 'scorecards',
          attributes: {
            name: FFaker::Lorem.words(4).join(' '),
            description: FFaker::Lorem.words(10).join(' '),
          },
          relationships: {
            client: { data: { id: client.id } },
            community: { data: { id: community.id } }
          }
        }


        included_attributes = [{
          type: 'wicked_problems',
          attributes: {
            name: FFaker::Lorem.words(4).join(' '),
            description: FFaker::Lorem.words(10).join(' '),
          },
          relationships: {
            client: { data: { id: client.id } }
          }
        }]

        sign_in(admin)

        expect do
          post '/scorecards', data: data_attributes, included: included_attributes
        end.to change{ WickedProblem.count }.by(1)

        expect(response).to have_http_status(201)

        new_wicked_problem = WickedProblem.last
        expect(new_wicked_problem.name).to eq(included_attributes.first[:attributes][:name])
        expect(new_wicked_problem.description).to eq(included_attributes.first[:attributes][:description])
        expect(new_wicked_problem.client).to eq(client)

        scorecard = Scorecard.last
        expect(scorecard.wicked_problem).to eq(new_wicked_problem)
      end
    end
  end

  describe "PUT /scorecards" do
    let(:data_attributes) {
      {
        type: 'scorecards',
        attributes: {
          name: FFaker::Lorem.words(4).join(' '),
          description: FFaker::Lorem.words(10).join(' '),
        },
        relationships: {
          community: { data: { id: community.id } },
          client: { data: { id: client.id } }
        }
      }
    }

    specify "updating as admin" do
      sign_in(admin)
      put "/scorecards/#{scorecard.id}", data: data_attributes
      scorecard.reload

      expect(response).to have_http_status(200)
      expect(scorecard.name).to eq(data_attributes[:attributes][:name])
      expect(scorecard.description).to eq(data_attributes[:attributes][:description])
    end

    specify "updating as admin - change community" do
      scorecard_old_name = scorecard.name
      scorecard_old_description = scorecard.description
      scorecard_old_client_id = scorecard.client_id

      new_community = create(:community, client: client)

      sign_in(admin)
      data_attributes = {
        type: 'scorecards',
        relationships: {
          community: { data: { id: new_community.id } }
        }
      }

      put "/scorecards/#{scorecard.id}", data: data_attributes
      scorecard.reload

      expect(response).to have_http_status(200)
      expect(scorecard.name).to eq(scorecard_old_name)
      expect(scorecard.description).to eq(scorecard_old_description)
      expect(scorecard.client.id).to eq(scorecard_old_client_id)
      expect(scorecard.community.id).to eq(new_community.id)
    end
  end
end

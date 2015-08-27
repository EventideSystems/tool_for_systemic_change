require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Initiatives", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  let!(:initiative) { create(:initiative, wicked_problem: wicked_problem, organisations: [organisation]) }
  let!(:other_initiative) {
    create(:initiative, wicked_problem: other_wicked_problem, organisations: [other_organisation]) }

  describe "GET /initiatives" do

    specify 'all fields returned' do
      sign_in(staff)
      get initiatives_path

      initiative_data = JSON.parse(response.body)['data'].first

      expect(initiative_data['id']).to eq(initiative.id.to_s)
      expect(initiative_data['attributes']['name']).to eq(initiative.name)
      expect(initiative_data['attributes']['description']).to eq(initiative.description)

      relationships_data = initiative_data['relationships']

      expect(relationships_data['wickedProblem']['data']['id'])
        .to eq(wicked_problem.id.to_s)
      expect(relationships_data['organisations']['data'].first['id'])
        .to eq(organisation.id.to_s)
    end

    describe "restrict access by role" do
      specify "user profile" do
        sign_in(user)
        get initiatives_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "admin profile" do
        sign_in(admin)
        get initiatives_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "staff profile" do
        sign_in(staff)
        get initiatives_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(2)
      end
    end
  end

  describe "GET /initiatives/:id" do

    describe "restrict access by role" do
      specify "user - accessible record" do
        sign_in(user)
        get initiative_path(initiative)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(initiative.id.to_s)
      end

      specify "user - inaccessible record" do
        sign_in(user)
        get initiative_path(other_initiative)

        expect(response).to have_http_status(403)
      end

      specify "admin - accessible record" do
        sign_in(admin)
        get initiative_path(initiative)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data']['id']).to eq(initiative.id.to_s)
      end

      specify "admin - inaccessible record" do
        sign_in(user)
        get initiative_path(other_initiative)

        expect(response).to have_http_status(403)
      end

      specify "staff - all records" do
        sign_in(staff)
        get initiative_path(initiative)

        expect(response).to have_http_status(200)

        get initiative_path(initiative)

        expect(response).to have_http_status(200)
      end
    end

  end

  describe "POST /initiatives" do
    let(:initiative_name) { FFaker::Lorem.words(4).join(' ') }
    let(:initiative_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'initiatives',
        attributes: {
          name: initiative_name,
          description: initiative_description,
        },
        # SMELL Not supporting wicked_problems relationship at this point, if
        # we do at all.
        relationships: {
          wicked_problem: { data: { id: wicked_problem.id } }
        }
      }
    }

    specify "posting as admin" do
      sign_in(admin)
      post '/initiatives', data: data_attributes

      expect(response).to have_http_status(201)

      new_initiative = Initiative.last
      expect(new_initiative.name).to eq(initiative_name)
      expect(new_initiative.description).to eq(initiative_description)
      expect(new_initiative.wicked_problem).to eq(wicked_problem)
    end
  end

  describe "PUT /initiatives/:id" do
    let(:initiative_new_name) { FFaker::Lorem.words(4).join(' ') }
    let(:initiative_new_description) { FFaker::Lorem.words(10).join(' ') }

    let(:data_attributes) {
      {
        type: 'initiatives',
        attributes: {
          name: initiative_new_name,
          description: initiative_new_description,
        },
        relationships: {
          wicked_problem: { data: { id: wicked_problem.id } }
        }
      }
    }

    specify "updating as admin" do
      sign_in(admin)
      put "/initiatives/#{initiative.id}", data: data_attributes
      initiative.reload

      expect(response).to have_http_status(200)
      expect(initiative.name).to eq(initiative_new_name)
      expect(initiative.description).to eq(initiative_new_description)
    end
  end
end

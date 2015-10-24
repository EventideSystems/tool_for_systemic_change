require "rails_helper"
require "shared_contexts"

RSpec.describe "Initiatives", type: :request do
  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  let!(:initiative) do
    create(:initiative,
           scorecard: scorecard,
           organisations: [organisation])
  end

  let!(:other_initiative) do
    create(:initiative,
           scorecard: other_scorecard,
           organisations: [other_organisation])
  end

  let!(:second_organisation) do
    create(:organisation,
           client: client)
  end

  describe "GET /initiatives" do
    specify "all fields returned" do
      sign_in(staff)
      get initiatives_path
      expect(response).to have_http_status(200)

      initiative_data = JSON.parse(response.body)["data"].first

      expect(initiative_data["id"]).to eq(initiative.id.to_s)
      expect(initiative_data["attributes"]["name"]).to eq(initiative.name)
      expect(initiative_data["attributes"]["description"]).
        to eq(initiative.description)
      expect(Time.parse(initiative_data["attributes"]["createdAt"]).utc).
        to be_within(0.01).of(initiative.created_at.utc)

      relationships_data = initiative_data["relationships"]

      expect(relationships_data["scorecard"]["data"]["id"]).
        to eq(scorecard.id.to_s)
      expect(relationships_data["organisations"]["data"].first["id"]).
        to eq(organisation.id.to_s)
    end

    describe "restrict access by role" do
      specify "user profile" do
        sign_in(user)
        get initiatives_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["data"].count).to be(1)
      end

      specify "admin profile" do
        sign_in(admin)
        get initiatives_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["data"].count).to be(1)
      end

      specify "staff profile" do
        sign_in(staff)
        get initiatives_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["data"].count).to be(2)
      end
    end
  end

  describe "GET /initiatives/:id" do
    describe "restrict access by role" do
      specify "user - accessible record" do
        sign_in(user)
        get initiative_path(initiative)

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["data"]["id"]).
          to eq(initiative.id.to_s)
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
        expect(JSON.parse(response.body)["data"]["id"]).
          to eq(initiative.id.to_s)
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
    let(:initiative_name) { FFaker::Lorem.words(4).join(" ") }
    let(:initiative_description) { FFaker::Lorem.words(10).join(" ") }

    let(:data_attributes) do
      {
        type: "initiatives",
        attributes: {
          name: initiative_name,
          description: initiative_description,
          started_at: "2015-10-10",
          finished_at: "2015-11-10",
          dates_confirmed: true
        },
        # SMELL Not supporting scorecards relationship at this point, if
        # we do at all.
        relationships: {
          scorecard: { data: { id: scorecard.id } },
          organisations: { data: [
            { id: organisation.id },
            { id: second_organisation.id }
          ] }
        }
      }
    end

    specify "posting as admin" do
      sign_in(admin)
      post "/initiatives", data: data_attributes

      expect(response).to have_http_status(201)

      new_initiative = Initiative.last
      expect(new_initiative.name).to eq(initiative_name)
      expect(new_initiative.description).to eq(initiative_description)
      expect(new_initiative.scorecard).to eq(scorecard)
      expect(new_initiative.started_at.to_s(:db)).to eq("2015-10-10")
      expect(new_initiative.finished_at.to_s(:db)).to eq("2015-11-10")
      expect(new_initiative.dates_confirmed).to be(true)
      expect(new_initiative.organisations.count).to be(2)
      expect(new_initiative.organisations.first).to eq(organisation)
      expect(new_initiative.organisations.second).to eq(second_organisation)
    end
  end

  describe "PUT /initiatives/:id" do
    let(:initiative_new_name) { FFaker::Lorem.words(4).join(" ") }
    let(:initiative_new_description) { FFaker::Lorem.words(10).join(" ") }

    let(:data_attributes) do
      {
        type: "initiatives",
        attributes: {
          name: initiative_new_name,
          description: initiative_new_description,
          started_at: "2015-09-10",
          finished_at: "2015-11-10",
          dates_confirmed: false
        },
        relationships: {
          scorecard: { data: { id: scorecard.id } }

        }
      }
    end

    specify "updating as admin" do
      sign_in(admin)
      put "/initiatives/#{initiative.id}", data: data_attributes
      initiative.reload

      expect(response).to have_http_status(200)
      expect(initiative.name).to eq(initiative_new_name)
      expect(initiative.description).to eq(initiative_new_description)
      expect(initiative.scorecard).to eq(scorecard)
      expect(initiative.started_at.to_s(:db)).to eq("2015-09-10")
      expect(initiative.finished_at.to_s(:db)).to eq("2015-11-10")
      expect(initiative.dates_confirmed).to be(false)
    end

    specify "updating as admin - only change name" do
      sign_in(admin)
      data_attributes[:attributes].delete(:description)

      initiative_old_description = initiative.description

      put "/initiatives/#{initiative.id}", data: data_attributes
      initiative.reload

      expect(response).to have_http_status(200)
      expect(initiative.name).to eq(initiative_new_name)
      expect(initiative.description).to eq(initiative_old_description)
    end

    specify "updating as admin - adding organisations" do
      sign_in(admin)

      data_attributes = {
        type: "initiatives",
        relationships: {
          organisations: { data: [
            { id: organisation.id },
            { id: second_organisation.id }
          ] }
        }
      }

      put "/initiatives/#{initiative.id}", data: data_attributes
      initiative.reload

      expect(response).to have_http_status(200)
      expect(initiative.organisations.count).to be(2)
      expect(initiative.organisations.first).to eq(organisation)
      expect(initiative.organisations.second).to eq(second_organisation)
    end

    specify "updating as admin - adding contact details" do
      sign_in(admin)

      data_attributes = {
        type: "initiatives",
        attributes: {
          contact_name: FFaker::Lorem.words(4).join(" "),
          contact_email: FFaker::Internet.email,
          contact_phone: FFaker::PhoneNumberAU.phone_number,
          contact_website: FFaker::Internet.http_url,
          contact_position: FFaker::Lorem.words(4).join(" ")
        }
      }

      put "/initiatives/#{initiative.id}", data: data_attributes
      initiative.reload

      expect(response).to have_http_status(200)
      attributes = data_attributes[:attributes]

      expect(initiative.contact_name).to eq(attributes[:contact_name])
      expect(initiative.contact_email).to eq(attributes[:contact_email])
      expect(initiative.contact_website).to eq(attributes[:contact_website])
      expect(initiative.contact_position).to eq(attributes[:contact_position])
    end

    specify "updating as admin - invalid finish date" do
      sign_in(admin)

      data_attributes = {
        type: "initiatives",
        attributes: {
          started_at: "2015-11-10",
          finished_at: "2015-09-10"
        }
      }

      put "/initiatives/#{initiative.id}", data: data_attributes

      expect(response).to have_http_status(422)
      error = JSON.parse(response.body)
      expect(error["finished_at"]).
        to include("can't be earlier than started at date")
    end
  end
end

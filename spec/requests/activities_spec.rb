require "rails_helper"
require "shared_contexts"

RSpec.describe "Activities", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"
  include_context "setup model data"


  describe "GET /activities" do

    describe "scorecard activity" do
      let(:scorecard_name) { FFaker::Lorem.words(4).join(" ") }
      let(:scorecard_description) { FFaker::Lorem.words(10).join(" ") }

      let(:data_attributes) {
        {
          type: "scorecards",
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

      before(:each) do
        sign_in(admin)

        post "/scorecards", data: data_attributes
        expect(response).to have_http_status(201)
        @new_scorecard = Scorecard.last
      end

      specify "retrieve scorecard created activity" do
        get activities_path
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)["data"]
        expect(data.count).to satisfy { |c| c > 0 }
        expect(data.first["attributes"]["trackableId"]).to eq(@new_scorecard.id)
        expect(data.first["attributes"]["trackableType"]).to eq("Scorecard")
        expect(data.first["attributes"]["action"]).to eq("create")
      end

      specify "retrieve scorecard activity message" do
        get activities_path
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)["data"]
        expect(data.first["attributes"]["shortMessage"])
          .to eq("Scorecard created")
        expect(data.first["attributes"]["longMessage"])
          .to eq("Scorecard '#{scorecard_name}' created by #{admin.name}")
      end

      specify "retrieve scorecard updated activity" do
        put "/scorecards/#{@new_scorecard.id}", data: data_attributes
        @new_scorecard.reload

        get activities_path
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)["data"]
        expect(data.count).to satisfy { |c| c > 0 }
        expect(data.first["attributes"]["trackableId"]).to eq(@new_scorecard.id)
        expect(data.first["attributes"]["trackableType"]).to eq("Scorecard")
        expect(data.first["attributes"]["action"]).to eq("update")
      end

      specify "retrieve scorecard activity with filter" do
        get activities_path, trackable_type: "Scorecard"
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)["data"]
        expect(data.count).to satisfy { |c| c > 0 }
        expect(data.first["attributes"]["trackableId"]).to eq(@new_scorecard.id)
        expect(data.first["attributes"]["trackableType"]).to eq("Scorecard")
      end
    end

    describe "checklist item activity" do

      let!(:initiative) do
        create(:initiative,
               scorecard: scorecard,
               organisations: [organisation])
      end

      before(:each) do
        PublicActivity::Activity.delete_all

        data_attributes = initiative.checklist_items.map do |item|
          { id: item.id,
            type: 'checklist_items',
            attributes: {
              checked: true,
              comment: FFaker::Lorem.words.join(' ')
            }
          }
        end

        sign_in(staff)
        put "/initiatives/#{initiative.id}/checklist_items", data: data_attributes
      end

      specify "retrieve scorecard created activity" do
        get activities_path
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)["data"]

        expect(data.last["attributes"]["trackableId"]).
         to be(initiative.checklist_items.first.id)
      end

      specify "retrieve scorecard created activity with filter" do
        get activities_path, trackable_type: "ChecklistItem"
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)["data"]

        expect(data.last["attributes"]["trackableId"]).
         to be(initiative.checklist_items.first.id)
      end

      specify "retrieve scorecard created activity with limit" do
        get activities_path, limit: 20
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)["data"]

        expect(data.count).to be(20)
      end

      specify "retrieve scorecard created activity with pagination" do
        expect(initiative.checklist_items.count).to be(36)

        get activities_path, trackable_type: "ChecklistItem", page: 1, per: 20
        expect(response).to have_http_status(200)
        data = JSON.parse(response.body)["data"]
        expect(data.count).to be(20)

        get activities_path, trackable_type: "ChecklistItem", page: 2, per: 20
        expect(response).to have_http_status(200)
        data = JSON.parse(response.body)["data"]
        expect(data.count).to be(16)
      end
    end

    describe "invalid request" do
      specify "request invalid trackable type" do
        get activities_path, trackable_type: "Characteristic"

        expect(response).to have_http_status(401)
      end
    end
  end
end

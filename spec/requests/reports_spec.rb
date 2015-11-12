require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Organisations", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  let!(:community_2) { create(:community, client: client) }
  let!(:wicked_problem_2) { create(:wicked_problem, client: client) }

  let!(:scorecard_2) { create(:scorecard,
      client: client,
      community: community_2,
      wicked_problem: wicked_problem) }

  let!(:scorecard_3) { create(:scorecard,
      client: client,
      community: community_2,
      wicked_problem: wicked_problem_2) }

  let!(:initiative_1) do
    create(:initiative,
           scorecard: scorecard,
           organisations: [organisation])
  end

  let!(:initiative_2) do
    create(:initiative,
           scorecard: scorecard,
           organisations: [organisation])
  end

  let!(:initiative_3) do
    create(:initiative,
           scorecard: scorecard_2,
           organisations: [organisation])
  end

  let!(:initiative_4) do
    create(:initiative,
           scorecard: scorecard_3,
           organisations: [organisation])
  end

  describe "GET /reports/initiatives" do

    specify "initiatives for a wicked problem" do
      sign_in(admin)

      get reports_initiatives_path, wicked_problem_id: wicked_problem.id

      expect(JSON.parse(response.body)["data"].count).to be(3)
    end

    specify "initiatives for multiple wicked problems" do
      sign_in(admin)

      get reports_initiatives_path, wicked_problem_id: [wicked_problem.id, wicked_problem_2.id]

      expect(JSON.parse(response.body)["data"].count).to be(4)
    end

    specify "initiatives for a community" do
      sign_in(admin)

      get reports_initiatives_path, community_id: community.id

      expect(JSON.parse(response.body)["data"].count).to be(2)
    end

    specify "initiatives for multiple communities" do
      sign_in(admin)

      get reports_initiatives_path, community_id: [community.id, community_2.id]

      expect(JSON.parse(response.body)["data"].count).to be(4)
    end

    specify "initiatives for specific community and wicked problem" do
      sign_in(admin)

      get reports_initiatives_path, community_id: community_2.id, wicked_problem_id: wicked_problem_2.id

      expect(JSON.parse(response.body)["data"].count).to be(1)
    end
  end

  describe "GET /reports/stakeholders" do


    specify "organisations for a wicked problem" do
      sign_in(admin)

      Bullet.enable = false
      get reports_stakeholders_path
      Bullet.enable = true

      expect(JSON.parse(response.body)["data"].count).to be(1)
    end


  end
end



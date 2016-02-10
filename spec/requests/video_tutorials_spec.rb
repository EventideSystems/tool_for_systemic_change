require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Video Tutorials", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "Listing videos" do

    before(:each) do
      sign_in(user)
    end

    specify "returns vimeo link" do
      create(:video_tutorial, link_url: "https://vimeo.com/49487948")

      get video_tutorials_path

      attributes = JSON.parse(response.body)["data"].first["attributes"]
      expect(attributes["vimeoId"]).to eq("49487948")
    end

    specify "returns linked object attributes" do

      focus_area = FocusArea.first

      create(
        :video_tutorial,
        link_url: "https://vimeo.com/123567",
        linked: focus_area
      )

      get video_tutorials_path

      attributes = JSON.parse(response.body)["data"].first["attributes"]

      expect(attributes["linkedId"]).to eq(focus_area.id)
      expect(attributes["linkedType"]).to eq("FocusArea")
      expect(attributes["linkedName"]).to eq(focus_area.name)
    end

    specify "returns vimeo links promoted to dashboard in position order" do
      create(
        :video_tutorial,
        link_url: "https://vimeo.com/123567",
        position: 2,
        promote_to_dashboard: true
      )

      create(
        :video_tutorial,
        link_url: "https://vimeo.com/8901234",
        position: 1,
        promote_to_dashboard: true
      )

      # NOTE Should not be included
      create(
        :video_tutorial,
        link_url: "https://vimeo.com/7777777"
      )

      skip_bullet do
        get dashboard_video_tutorials_path
      end

      video_links_data = JSON.parse(response.body)["data"]

      expect(video_links_data.count).to be(2)
      expect(video_links_data[0]["attributes"]["vimeoId"]).to eq("8901234")
      expect(video_links_data[1]["attributes"]["vimeoId"]).to eq("123567")
    end
  end
end

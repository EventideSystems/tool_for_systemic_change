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
  end
end

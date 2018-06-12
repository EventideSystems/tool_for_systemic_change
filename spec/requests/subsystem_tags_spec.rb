require 'rails_helper'

RSpec.describe "SubsystemTags", type: :request do
  describe "GET /subsystem_tags" do
    it "works! (now write some real specs)" do
      get subsystem_tags_path
      expect(response).to have_http_status(200)
    end
  end
end

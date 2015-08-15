require 'rails_helper'

RSpec.describe "Wicked Problems", type: :request do
  describe "GET /wicked_problems" do
    it "works! (now write some real specs)" do
      get wicked_problems_path
      expect(response).to have_http_status(200)
    end
  end
end

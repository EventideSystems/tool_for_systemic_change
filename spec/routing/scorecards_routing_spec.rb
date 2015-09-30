require "rails_helper"

RSpec.describe ScorecardsController, type: :routing do
  describe "routing" do

  # SMELL Commenting out. This seems to be an issue with new RSpec route specs

    it "routes to #index" do
      expect(:get => "/scorecards").to route_to("scorecards#index", :format => 'json')
    end

    it "routes to #new" do
      expect(:get => "/scorecards/new").to route_to("scorecards#new", :format => 'json')
    end

    it "routes to #show" do
      expect(:get => "/scorecards/1").to route_to("scorecards#show", :id => "1", :format => 'json')
    end

    it "routes to #edit" do
      expect(:get => "/scorecards/1/edit").to route_to("scorecards#edit", :id => "1", :format => 'json')
    end

    it "routes to #create" do
      expect(:post => "/scorecards").to route_to("scorecards#create", :format => 'json')
    end

    it "routes to #update via PUT" do
      expect(:put => "/scorecards/1").to route_to("scorecards#update", :id => "1", :format => 'json')
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/scorecards/1").to route_to("scorecards#update", :id => "1", :format => 'json')
    end

    it "routes to #destroy" do
      expect(:delete => "/scorecards/1").to route_to("scorecards#destroy", :id => "1", :format => 'json')
    end

  end
end

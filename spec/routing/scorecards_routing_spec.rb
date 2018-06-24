require "rails_helper"

RSpec.describe ScorecardsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/transition_cards").to route_to("scorecards#index")
    end

    it "routes to #new" do
      expect(:get => "/transition_cards/new").to route_to("scorecards#new")
    end

    it "routes to #show" do
      expect(:get => "/transition_cards/1").to route_to("scorecards#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/transition_cards/1/edit").to route_to("scorecards#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/transition_cards").to route_to("scorecards#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/transition_cards/1").to route_to("scorecards#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/transition_cards/1").to route_to("scorecards#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/transition_cards/1").to route_to("scorecards#destroy", :id => "1")
    end

  end
end
require "rails_helper"

RSpec.describe Initiatives::ImportsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/initiatives/imports").to route_to("initiatives/imports#index")
    end

    it "routes to #new" do
      expect(:get => "/initiatives/imports/new").to route_to("initiatives/imports#new")
    end

    it "routes to #show" do
      expect(:get => "/initiatives/imports/1").to route_to("initiatives/imports#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/initiatives/imports/1/edit").to route_to("initiatives/imports#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/initiatives/imports").to route_to("initiatives/imports#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/initiatives/imports/1").to route_to("initiatives/imports#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/initiatives/imports/1").to route_to("initiatives/imports#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/initiatives/imports/1").to route_to("initiatives/imports#destroy", :id => "1")
    end

  end
end

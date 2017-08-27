require "rails_helper"

RSpec.describe Organisations::ImportsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/organisations/imports").to route_to("organisations/imports#index")
    end

    it "routes to #new" do
      expect(:get => "/organisations/imports/new").to route_to("organisations/imports#new")
    end

    it "routes to #show" do
      expect(:get => "/organisations/imports/1").to route_to("organisations/imports#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/organisations/imports/1/edit").to route_to("organisations/imports#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/organisations/imports").to route_to("organisations/imports#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/organisations/imports/1").to route_to("organisations/imports#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/organisations/imports/1").to route_to("organisations/imports#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/organisations/imports/1").to route_to("organisations/imports#destroy", :id => "1")
    end

  end
end

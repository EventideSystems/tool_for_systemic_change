require "rails_helper"

RSpec.describe SubsystemTagsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/subsystem_tags").to route_to("subsystem_tags#index")
    end

    it "routes to #new" do
      expect(:get => "/subsystem_tags/new").to route_to("subsystem_tags#new")
    end

    it "routes to #show" do
      expect(:get => "/subsystem_tags/1").to route_to("subsystem_tags#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/subsystem_tags/1/edit").to route_to("subsystem_tags#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/subsystem_tags").to route_to("subsystem_tags#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/subsystem_tags/1").to route_to("subsystem_tags#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/subsystem_tags/1").to route_to("subsystem_tags#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/subsystem_tags/1").to route_to("subsystem_tags#destroy", :id => "1")
    end

  end
end

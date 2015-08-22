require "rails_helper"

RSpec.describe OrganisationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/organisations").to route_to("organisations#index", :format => 'json')
    end

    it "routes to #new" do
      expect(:get => "/organisations/new").to route_to("organisations#new", :format => 'json')
    end

    it "routes to #show" do
      expect(:get => "/organisations/1").to route_to("organisations#show", :id => "1", :format => 'json')
    end

    it "routes to #edit" do
      expect(:get => "/organisations/1/edit").to route_to("organisations#edit", :id => "1", :format => 'json')
    end

    it "routes to #create" do
      expect(:post => "/organisations").to route_to("organisations#create", :format => 'json')
    end

    it "routes to #update via PUT" do
      expect(:put => "/organisations/1").to route_to("organisations#update", :id => "1", :format => 'json')
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/organisations/1").to route_to("organisations#update", :id => "1", :format => 'json')
    end

    it "routes to #destroy" do
      expect(:delete => "/organisations/1").to route_to("organisations#destroy", :id => "1", :format => 'json')
    end

  end
end

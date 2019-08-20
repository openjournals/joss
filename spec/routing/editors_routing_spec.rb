require "rails_helper"

RSpec.describe EditorsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get: "/editors").to route_to("editors#index")
    end

    it "routes to #new" do
      expect(get: "/editors/new").to route_to("editors#new")
    end

    it "routes to #show" do
      expect(get: "/editors/1").to route_to("editors#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/editors/1/edit").to route_to("editors#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/editors").to route_to("editors#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/editors/1").to route_to("editors#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/editors/1").to route_to("editors#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/editors/1").to route_to("editors#destroy", id: "1")
    end

  end
end

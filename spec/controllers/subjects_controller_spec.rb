require 'rails_helper'

describe SubjectsController, type: :controller do
  render_views

  describe "GET #search" do
    it "should find using the query param" do
      create(:subject, name: "Astronomy", track: create(:track, id: 1))
      create(:subject, name: "Entomology", track: create(:track, id: 2))
      create(:subject, name: "Food and Gastronomy", track: create(:track, id: 3))

      get :search, params: { q: "astro" }

      expect(response).to be_successful

      expect(response.body).to match "Astronomy"
      expect(response.body).to match "data-autocomplete-value=\"1\""

      expect(response.body).to match "Food and Gastronomy"
      expect(response.body).to match "data-autocomplete-value=\"3\""

      expect(response.body).to_not match "Entomology"
      expect(response.body).to_not match "data-autocomplete-value=\"2\""
    end
  end
end

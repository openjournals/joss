require 'rails_helper'

describe HomeController, :type => :controller do
  render_views

  describe "GET #index" do
    it "should render home page" do
      get :index, :format => :html
      expect(response).to be_success
      expect(response.body).to match /The Journal of Open Source Software/
    end
  end

  describe "GET #about" do
    it "should render about page" do
      get :about, :format => :html
      expect(response).to be_success
      expect(response.body).to match /Don't we have enough journals already?/
    end
  end

  describe "GET #editors" do
    it "should render editors page" do
      get :editors, :format => :html
      expect(response).to be_success
      expect(response.body).to match /Ya, we have editors/
    end
  end
end

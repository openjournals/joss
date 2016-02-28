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

  describe "LOGGED IN GET #index" do
    it "should render home page and ask for our email if we don't have one" do
      user = create(:user, :email => nil)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :index, :format => :html
      expect(response).to be_success
      expect(response.body).to match /Please add an email address to your account before continuing/
    end

    it "should render home page and ask for our email if we don't have one" do
      user = create(:user, :email => 'arfon@example.com')
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :index, :format => :html
      expect(response).to be_success
      expect(response.body).should_not match /Please add an email address to your account before continuing/
    end
  end

  describe "GET #about" do
    it "should render about page" do
      get :about, :format => :html
      expect(response).to be_success
      expect(response.body).to match /Don't we have enough journals already?/
    end
  end


  describe "POST #update_email" do
    it "should update their email address" do
      user = create(:user, :email => nil)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      params = {:email => "albert@gmail.com"}
      request.env["HTTP_REFERER"] = papers_path

      post :update_email, :user => params
      expect(response).to be_redirect # as it's updated the email
      expect(user.reload.email).to eq("albert@gmail.com")
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

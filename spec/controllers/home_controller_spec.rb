require 'rails_helper'

describe HomeController, type: :controller do
  render_views

  describe "GET #index" do
    it "should render home page" do
      get :index, format: :html
      expect(response).to be_successful
      expect(response.body).to match /The Journal of Open Source Software/
    end
  end

  describe "LOGGED IN GET #index" do
    it "should render home page and ask for our email if we don't have one" do
      user = create(:user, email: nil)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :index, format: :html
      expect(response).to be_successful
      expect(response.body).to match /you need to add your email address and GitHub handle/
    end

    it "should render home page and ask for a profile update if we don't have a github username" do
      user = create(:user, email: 'arfon@example.com', github_username: nil)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :index, format: :html
      expect(response).to be_successful
      expect(response.body).to match /you need to add your email address and GitHub handle/
    end
  end

  describe "GET #about" do
    it "should render about page" do
      get :about, :format => :html
      expect(response).to be_successful
      expect(response.body).to match /Why is this journal needed/
    end
  end

  describe "GET #profile" do
    it "should render profile page without 'update my profile banner'" do
      user = create(:user, email: nil, github_username: nil)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      # FIXME: Fix this test
      # get :profile, format: :html
      # expect(response).to be_successful
      # expect(response.body).not_to match /Please update your profile before continuing/
    end
  end

  describe "POST #update_profile" do
    it "should update their email address" do
      user = create(:user, email: nil, github_username: nil)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      params = {email: "albert@gmail.com", github_username: "@jimmy"}
      request.env["HTTP_REFERER"] = papers_path

      post :update_profile, params: {user: params}
      expect(response).to be_redirect # as it's updated the email
      expect(user.reload.email).to eq("albert@gmail.com")
      expect(user.reload.github_username).to eq("@jimmy")
    end

    it "should add an @ to their GitHub username if they don't use one" do
      user = create(:user, email: nil, github_username: nil)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      params = {email: "albert@gmail.com", github_username: "jimmy_no_at"}
      request.env["HTTP_REFERER"] = papers_path

      post :update_profile, params: {user: params}
      expect(response).to be_redirect # as it's updated the email
      expect(user.reload.email).to eq("albert@gmail.com")
      expect(user.reload.github_username).to eq("@jimmy_no_at")
    end
  end
end

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
      get :about, format: :html
      expect(response).to be_successful
      expect(response.body).to match /Don't we have enough journals already?/
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

  describe "GET #activity" do
    before { skip_paper_repo_url_check }

    let(:current_user) { create(:user, editor: create(:editor)) }
    let(:track_a) { create(:track) }
    let(:track_b) { create(:track) }
    let(:paper_a) { create(:review_pending_paper, track: track_a, meta_review_issue_id: 101) }
    let(:paper_b) { create(:review_pending_paper, track: track_b, meta_review_issue_id: 201) }

    before { allow(controller).to receive(:current_user).and_return(current_user) }

    context "when not logged in" do
      let(:current_user) { nil }
      it "redirects to root" do
        get :activity
        expect(response).to redirect_to root_path
        expect(flash[:error]).to eql "Please login first"
      end
    end

    context "when logged in as a non-editor user" do
      let(:current_user) { create(:user) }
      it "redirects to root" do
        get :activity
        expect(response).to redirect_to root_path
        expect(flash[:error]).to eql "You are not permitted to view that page"
      end
    end

    it "is available to any editor, not only AEiCs" do
      get :activity
      expect(response).to be_successful
      expect(response.body).to have_content "Issue activity"
      expect(response.body).to have_content "no comments from non-editor accounts"
    end

    it "lists commenters ranked by distinct issues, excluding editors and the bot" do
      create(:issue_comment, login: "spammer", paper: paper_a, issue_id: 101)
      create(:issue_comment, login: "spammer", paper: paper_b, issue_id: 201)
      create(:issue_comment, login: "reviewer", paper: paper_a, issue_id: 101, role: "reviewer")
      create(:issue_comment, login: "editorialbot", paper: paper_a, issue_id: 101, role: "bot")

      get :activity

      expect(response).to be_successful
      expect(response.body).to have_link("@spammer", href: "https://github.com/spammer")
      expect(response.body).to have_link("@reviewer", href: "https://github.com/reviewer")
      expect(response.body).to_not have_link("@editorialbot")
      expect(response.body.index("@spammer")).to be < response.body.index("@reviewer")
    end

    it "respects the days window" do
      create(:issue_comment, login: "old_spammer", paper: paper_a, issue_id: 101, commented_at: 3.days.ago)

      get :activity, params: { days: 1 }
      expect(response.body).to_not have_link("@old_spammer")

      get :activity, params: { days: 7 }
      expect(response.body).to have_link("@old_spammer")
    end

    it "falls back to the default window for unknown values" do
      get :activity, params: { days: 999 }
      expect(response.body).to have_css("strong", text: "Last 7 days")
      expect(response.body).to have_link("Last 24 hours")
      expect(response.body).to have_link("Last 30 days")
    end

    it "filters by track" do
      create(:issue_comment, login: "track_a_person", paper: paper_a, issue_id: 101)
      create(:issue_comment, login: "track_b_person", paper: paper_b, issue_id: 201)

      get :activity, params: { track_id: track_b.id }

      expect(response.body).to have_content "Track: #{track_b.name}"
      expect(response.body).to have_link("@track_b_person")
      expect(response.body).to_not have_link("@track_a_person")
    end

    it "lists the comments of a selected login" do
      create(:issue_comment, login: "spammer", paper: paper_a, issue_id: 101, comment_url: "https://github.com/x/y/issues/101#issuecomment-1")
      create(:issue_comment, login: "spammer", paper: paper_b, issue_id: 201, comment_url: "https://github.com/x/y/issues/201#issuecomment-2")
      create(:issue_comment, login: "other", paper: paper_a, issue_id: 101)

      get :activity, params: { login: "spammer" }

      expect(response.body).to have_content "Comments by @spammer"
      expect(response.body).to have_link("#101")
      expect(response.body).to have_link("#201")
      expect(response.body).to have_link("View on GitHub →", href: "https://github.com/x/y/issues/101#issuecomment-1")
      expect(response.body).to have_content paper_a.title
    end
  end
end

require 'rails_helper'

RSpec.describe AeicDashboardController, type: :controller do
  render_views
  let(:current_user) { create(:user, editor: create(:board_editor)) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when not logged in" do
    let(:current_user) { nil }
    it "redirects to root with a login message" do
      get :index
      expect(response).to redirect_to root_path
      expect(flash[:error]).to eql "Please login first"
    end
  end

  context "when logged in as a non-editor user" do
    let(:current_user) { create(:user) }
    it "redirects to root with a not allowed message" do
      get :index
      expect(response).to redirect_to root_path
      expect(flash[:error]).to eql "You are not permitted to view that page"
    end
  end

  context "when logged in as a non-aeic editor" do
    let(:current_user) { create(:user, editor: create(:editor)) }
    it "redirects to root with a not allowed message" do
      get :index
      expect(response).to redirect_to root_path
      expect(flash[:error]).to eql "You are not permitted to view that page"
    end
  end

  describe "#index" do
    let(:accepted_params) { [Rails.application.settings[:reviews], {labels: "recommend-accept", state: "open"}] }
    let(:flagged_params) { [Rails.application.settings[:reviews], {labels: "query-scope", state: "open"}] }
    let(:accepted_issue_1) { OpenStruct.new(number: 1, html_url: "/test1", title: "Accepted paper 1") }
    let(:accepted_issue_2) { OpenStruct.new(number: 2, html_url: "/test2", title: "Accepted paper 2") }
    let(:flagged_issue_1) { OpenStruct.new(number: 3, html_url: "/test3", title: "Flagged paper 1") }
    let(:flagged_issue_2) { OpenStruct.new(number: 4, html_url: "/test4", title: "Flagged paper 2") }

    it "lists all open accepted issues" do
      allow(GITHUB).to receive(:issues).with(*accepted_params).and_return([accepted_issue_1, accepted_issue_2])
      allow(GITHUB).to receive(:issues).with(*flagged_params).and_return([])

      get :index

      expect(response.body).to have_content "List of ready to publish submissions at GitHub"
      expect(response.body).to have_link("#1", href: "/test1")
      expect(response.body).to have_link("#2", href: "/test2")
      expect(response.body).to have_content "Accepted paper 1"
      expect(response.body).to have_content "Accepted paper 2"
      expect(response.body).to_not have_content "There are no open submissions labeled as recommend-accept"
    end

    it "includes a no submissions message if there are not open accepted issues" do
      allow(GITHUB).to receive(:issues).with(*accepted_params).and_return([])
      allow(GITHUB).to receive(:issues).with(*flagged_params).and_return([flagged_issue_1])

      get :index

      expect(response.body).to have_content "There are no open submissions labeled as recommend-accept"
      expect(response.body).to_not have_content "List of ready to publish submissions at GitHub"
    end

    it "lists all issues flagged with query-scope" do
      allow(GITHUB).to receive(:issues).with(*flagged_params).and_return([flagged_issue_1, flagged_issue_2])
      allow(GITHUB).to receive(:issues).with(*accepted_params).and_return([])

      get :index

      expect(response.body).to have_content "List of submissions pending editorial review at GitHub"
      expect(response.body).to have_link("#3", href: "/test3")
      expect(response.body).to have_link("#4", href: "/test4")
      expect(response.body).to have_content "Flagged paper 1"
      expect(response.body).to have_content "Flagged paper 2"
      expect(response.body).to_not have_content "There are no open submissions flagged for editorial review"
    end

    it "includes a no submissions message if there are not open flagged issues" do
      allow(GITHUB).to receive(:issues).with(*flagged_params).and_return([])
      allow(GITHUB).to receive(:issues).with(*accepted_params).and_return([accepted_issue_1])

      get :index

      expect(response.body).to have_content "There are no open submissions flagged for editorial review"
      expect(response.body).to_not have_content "List of submissions pending editorial review at Github"
    end
  end

  describe "#activity" do
    before { skip_paper_repo_url_check }

    let(:track_a) { create(:track) }
    let(:track_b) { create(:track) }
    let(:paper_a) { create(:review_pending_paper, track: track_a, meta_review_issue_id: 101) }
    let(:paper_b) { create(:review_pending_paper, track: track_b, meta_review_issue_id: 201) }

    context "when not logged in as an AEiC" do
      let(:current_user) { create(:user, editor: create(:editor)) }
      it "redirects to root" do
        get :activity
        expect(response).to redirect_to root_path
      end
    end

    it "shows an empty message when there is no activity" do
      get :activity
      expect(response).to be_successful
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
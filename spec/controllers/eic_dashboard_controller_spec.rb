require 'rails_helper'

RSpec.describe EicDashboardController, type: :controller do
  render_views
  let(:current_user) { create(:admin_user, editor: create(:editor)) }

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

  context "when logged in as a non-admin user" do
    let(:current_user) { create(:user) }
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
end
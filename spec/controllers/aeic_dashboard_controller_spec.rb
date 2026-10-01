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

  describe "#editor_emails" do
    let!(:topic_editor) { create(:editor, first_name: "Topic", last_name: "Person", email: "topic@example.com") }
    let!(:pending_editor) { create(:pending_editor, email: "pending@example.com") }
    let!(:emeritus_editor) { create(:emeritus_editor, email: "emeritus@example.com") }

    before { current_user.editor.update!(email: "aeic@example.com") }

    it "shows download links for both groups" do
      get :editor_emails

      expect(response.body).to have_link("EiC & AEiC emails (#{Editor.board.count})", href: aeic_editor_emails_path(format: :csv, group: "board"))
      expect(response.body).to have_link("Topic editor emails (#{Editor.topic.count})", href: aeic_editor_emails_path(format: :csv, group: "topic"))
    end

    it "downloads board editor emails" do
      get :editor_emails, params: { group: "board" }, format: :csv

      expect(response.media_type).to eq "text/csv"
      expect(response.headers["Content-Disposition"]).to include "aeic-editor-emails"
      rows = CSV.parse(response.body, headers: true)
      emails = rows.map { |r| r["email"] }
      expect(emails.size).to eq Editor.board.count
      expect(emails).to include "aeic@example.com"
      expect(emails).to_not include "topic@example.com", "pending@example.com", "emeritus@example.com"
    end

    it "downloads topic editor emails" do
      get :editor_emails, params: { group: "topic" }, format: :csv

      rows = CSV.parse(response.body, headers: true)
      expect(rows.map { |r| r["email"] }).to eq ["topic@example.com"]
      expect(rows.first["login"]).to eq topic_editor.login
    end

    it "returns not found for an unknown group" do
      get :editor_emails, params: { group: "emeritus" }, format: :csv
      expect(response).to have_http_status(:not_found)
    end

    context "when logged in as a non-aeic editor" do
      let(:current_user) { create(:user, editor: create(:editor)) }
      it "does not allow downloads" do
        get :editor_emails, params: { group: "board" }, format: :csv
        expect(response).to redirect_to root_path
      end
    end
  end
end

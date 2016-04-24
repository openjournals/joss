require 'rails_helper'

describe PapersController, :type => :controller do
  render_views

  describe "GET #index" do
    it "should render all visible papers" do
      get :index, :format => :html
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    it "NOT LOGGED IN responds with redirect" do
      paper_params = {:title => "Yeah whateva", :body => "something"}
      post :create, :paper => paper_params
      expect(response).to be_redirect
    end
  end

  describe "POST #create" do
    it "LOGGED IN responds with success" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper_count = Paper.count

      paper_params = {:title => "Yeah whateva", :body => "something", :repository_url => "https://github.com/foo/bar", :archive_doi => "http://dx.doi.org/10.6084/m9.figshare.828487", :software_version => "v1.0.1"}
      post :create, :paper => paper_params
      expect(response).to be_redirect # as it's created the thing
      expect(Paper.count).to eq(paper_count + 1)
    end

    it "LOGGED IN without complete params responds with errors" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper_count = Paper.count

      paper_params = {:title => "Yeah whateva", :body => "something", :repository_url => "", :archive_doi => "http://dx.doi.org/10.6084/m9.figshare.828487"}
      post :create, :paper => paper_params

      expect(response.body).to match /Your paper could not be saved/
      expect(Paper.count).to eq(paper_count)
    end

    it "LOGGED IN without a email on the submitting author account" do
      user = create(:user, :email => nil)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper_count = Paper.count
      request.env["HTTP_REFERER"] = new_paper_path

      paper_params = {:title => "Yeah whateva", :body => "something", :repository_url => "https://github.com/foo/bar", :archive_doi => "http://dx.doi.org/10.6084/m9.figshare.828487", :software_version => "v1.0.1"}
      post :create, :paper => paper_params
      expect(response).to be_redirect # as it's redirected us
      expect(Paper.count).to eq(paper_count)
    end
  end

  describe "status badges" do
    it "should return the correct status badge for a submitted paper" do
      submitted_paper = create(:paper, :state => 'submitted')

      get :status, :id => submitted_paper.sha, :format => "svg"
      expect(response.body).to match /Submitted/
    end

    it "should return the correct status badge for an accepted paper" do
      submitted_paper = create(:paper, :state => 'accepted')

      get :status, :id => submitted_paper.sha, :format => "svg"
      expect(response.body).to match /Accepted/
    end

    it "should return the correct status badge for an unknown paper" do
      get :status, :id => "asdasd", :format => "svg"
      expect(response.body).to match /Unknown/
    end
  end
end

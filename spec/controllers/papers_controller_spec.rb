require 'rails_helper'

describe PapersController, :type => :controller do
  render_views

  before(:each) do
    allow(Repository).to receive(:editors).and_return ["@user1", "@user2"]
  end

  describe "GET #index" do
    it "should render all visible papers" do
      get :index, :format => :html
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    it "NOT LOGGED IN responds with redirect" do
      paper_params = {:title => "Yeah whateva", :body => "something"}
      post :create, params: {:paper => paper_params}
      expect(response).to be_redirect
    end
  end

  describe "#start_meta_review" do
    it "NOT LOGGED IN responds with redirect" do
      post :start_meta_review, params: {:id => 'nothing much'}
      expect(response).to be_redirect
    end

    it "LOGGED IN and with correct params" do
      user = create(:admin_user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      author = create(:user)
      paper = create(:paper, :user_id => author.id)
      paper.sha = '48d24b0158528e85ac7706aecd8cddc4'
      paper.save

      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      post :start_meta_review, params: {:id => paper.sha, :editor => "joss"}
      expect(response).to be_redirect
    end
  end

  describe "POST #api_start_review" do
    ENV["WHEDON_SECRET"] = "mooo"

    it "with no API key" do
      post :api_start_review
      expect(response).to be_forbidden
    end

    it "with the wrong API key" do
      post :api_start_review, params: {:secret => "fooo"}
      expect(response).to be_forbidden
    end

    it "with the correct API key" do
      user = create(:user)
      paper = create(:review_pending_paper, :state => "review_pending", :meta_review_issue_id => 1234, :user_id => user.id)
      # TODO - work out how to skip callback so we don't have to set the SHA again for WebMock
      paper.sha = '48d24b0158528e85ac7706aecd8cddc4'
      paper.save

      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      post :api_start_review, params: {:secret => "mooo", :id => 1234, :reviewer => "mickey", :editor => "mouse"}
      expect(response).to be_created
    end
  end

  describe "Paper rejection" do
    it "should work for an administrator" do
      user = create(:admin_user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, :state => 'submitted')

      post :reject, params: {:id => submitted_paper.sha}
      expect(response).to be_redirect # as it's rejected the paper
      expect(Paper.rejected.count).to eq(1)
    end

    it "should fail for a standard user" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, :state => 'submitted')

      post :reject, params: {:id => submitted_paper.sha}
      expect(response).to be_redirect # as it's rejected the paper
      expect(Paper.rejected.count).to eq(0)
    end
  end

  describe "Paper withdrawing" do
    it "should work for an administrator" do
      user = create(:admin_user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, :state => 'submitted')

      post :withdraw, params: {:id => submitted_paper.sha}
      expect(response).to be_redirect # as it's rejected the paper
      expect(Paper.withdrawn.count).to eq(1)
    end

    it "should fail for a user who doesn't own the paper" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, :state => 'submitted')

      post :withdraw, params: {:id => submitted_paper.sha}
      expect(response).to be_redirect
      expect(Paper.withdrawn.count).to eq(0)
    end

    it "should work for a user who owns the paper" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, :state => 'submitted', :submitting_author => user)

      post :withdraw, params: {:id => submitted_paper.sha}
      expect(response).to be_redirect
      expect(Paper.withdrawn.count).to eq(1)
    end
  end

  describe "POST #create" do
    it "LOGGED IN responds with success" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper_count = Paper.count

      paper_params = {:title => "Yeah whateva", :body => "something", :repository_url => "https://github.com/foo/bar", :archive_doi => "https://doi.org/10.6084/m9.figshare.828487", :software_version => "v1.0.1"}
      post :create, params: {:paper => paper_params}
      expect(response).to be_redirect # as it's created the thing
      expect(Paper.count).to eq(paper_count + 1)
    end

    it "LOGGED IN without complete params responds with errors" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper_count = Paper.count

      paper_params = {:title => "Yeah whateva", :body => "something", :repository_url => "", :archive_doi => "https://doi.org/10.6084/m9.figshare.828487"}
      post :create, params: {:paper => paper_params}

      expect(response.body).to match /Your paper could not be saved/
      expect(Paper.count).to eq(paper_count)
    end

    it "LOGGED IN without a email on the submitting author account" do
      user = create(:user, :email => nil)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper_count = Paper.count
      request.env["HTTP_REFERER"] = new_paper_path

      paper_params = {:title => "Yeah whateva", :body => "something", :repository_url => "https://github.com/foo/bar", :archive_doi => "https://doi.org/10.6084/m9.figshare.828487", :software_version => "v1.0.1"}
      post :create, params: {:paper => paper_params}
      expect(response).to be_redirect # as it's redirected us
      expect(Paper.count).to eq(paper_count)
    end
  end

  describe "four oh four" do
    it "should 404 when passed an invalid sha" do
      get :show, params: {:id => SecureRandom.hex}, :format => "html"
      expect(response.body).to match /404 Not Found/
      expect(response.status).to eq(404)
    end

    it "should 404 when passed an invalid DOI" do
      get :show, params: {:id => "10.21105/1234"}, :format => "html"
      expect(response.body).to match /404 Not Found/
      expect(response.status).to eq(404)
    end
  end

  describe "paper lookup" do
    it "should return the created_at date for a paper" do
      submitted_paper = create(:paper, :state => 'submitted', :created_at => 3.days.ago, :meta_review_issue_id => 123)

      get :lookup, params: {:id => 123}
      expect(response.body).to eq(3.days.ago.strftime('%d %B %Y'))
    end

    it "should 404 when passed an invalid id" do
      get :lookup, params: {:id => 12345}

      expect(response.body).to match /404 Not Found/
      expect(response.status).to eq(404)
    end
  end

  describe "status badges" do
    it "should return the correct status badge for a submitted paper" do
      submitted_paper = create(:paper, :state => 'submitted')

      get :status, params: {:id => submitted_paper.sha}, :format => "svg"
      expect(response.body).to match /Submitted/
    end

    it "should return the correct status badge for an accepted paper" do
      submitted_paper = create(:paper, :state => 'accepted', :doi => "10.21105/joss.12345")

      get :status, params: {:id => submitted_paper.sha}, :format => "svg"
      expect(response.body).to match /10.21105/
    end

    it "should return the correct status badge for an unknown paper" do
      get :status, params: {:id => "asdasd"}, :format => "svg"
      expect(response.body).to match /Unknown/
    end
  end
end

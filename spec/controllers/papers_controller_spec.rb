require 'rails_helper'

describe PapersController, type: :controller do
  render_views

  before(:each) do
    allow(Repository).to receive(:editors).and_return ["@user1", "@user2"]
  end

  describe "GET #index" do
    it "should render all visible papers" do
      get :index, format: :html
      expect(response).to be_successful
    end
  end

  describe "#start_meta_review" do
    it "NOT LOGGED IN responds with redirect" do
      post :start_meta_review, params: {id: 'nothing much'}
      expect(response).to be_redirect
    end

    it "LOGGED IN and with correct params" do
      admin_editor = create(:editor, login: "josseic")
      admin_user = create(:admin_user, editor: admin_editor)
      editor = create(:editor, login: "josseditor")
      editing_user = create(:user, editor: editor)

      allow(controller).to receive_message_chain(:current_user).and_return(admin_user)

      author = create(:user)
      paper = create(:paper, user_id: author.id)

      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      post :start_meta_review, params: {id: paper.sha, editor: "josseditor"}

      expect(response).to be_redirect
      expect(paper.reload.state).to eq('review_pending')
      expect(paper.reload.eic).to eq(admin_editor)
    end
  end

  describe "Paper rejection" do
    it "should work for an administrator" do
      user = create(:admin_user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, state: 'submitted')

      post :reject, params: {id: submitted_paper.sha}
      expect(response).to be_redirect # as it's rejected the paper
      expect(Paper.rejected.count).to eq(1)
    end

    it "should fail for a standard user" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, state: 'submitted')

      post :reject, params: {id: submitted_paper.sha}
      expect(response).to be_redirect # as it's rejected the paper
      expect(Paper.rejected.count).to eq(0)
    end
  end

  describe "Paper withdrawing" do
    it "should work for an administrator" do
      user = create(:admin_user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, state: 'submitted')

      post :withdraw, params: {id: submitted_paper.sha}
      expect(response).to be_redirect # as it's rejected the paper
      expect(Paper.withdrawn.count).to eq(1)
    end

    it "should fail for a user who doesn't own the paper" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, state: 'submitted')

      post :withdraw, params: {id: submitted_paper.sha}
      expect(response).to be_redirect
      expect(Paper.withdrawn.count).to eq(0)
    end

    it "should work for a user who owns the paper" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, state: 'submitted', submitting_author: user)

      post :withdraw, params: {id: submitted_paper.sha}
      expect(response).to be_redirect
      expect(Paper.withdrawn.count).to eq(1)
    end
  end

  describe "POST #create" do

    it "LOGGED IN responds with success" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper_count = Paper.count

      paper_params = {title: "Yeah whateva", body: "something", repository_url: "https://github.com/openjournals/joss", archive_doi: "https://doi.org/10.6084/m9.figshare.828487", software_version: "v1.0.1", submission_kind: "new", suggested_editor: "@editor"}
      post :create, params: {paper: paper_params}
      expect(response).to be_redirect # as it's created the thing
      expect(Paper.count).to eq(paper_count + 1)
    end

    it "LOGGED IN without complete params responds with errors" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper_count = Paper.count

      paper_params = {title: "Yeah whateva", body: "something", repository_url: "", archive_doi: "https://doi.org/10.6084/m9.figshare.828487"}
      post :create, params: {paper: paper_params}

      expect(response.body).to match /Your paper could not be saved/
      expect(Paper.count).to eq(paper_count)
    end

    it "LOGGED IN without a email on the submitting author account" do
      user = create(:user, email: nil)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper_count = Paper.count
      request.env["HTTP_REFERER"] = new_paper_path

      paper_params = {title: "Yeah whateva", body: "something", repository_url: "https://github.com/foo/bar", archive_doi: "https://doi.org/10.6084/m9.figshare.828487", software_version: "v1.0.1"}
      post :create, params: {paper: paper_params}
      expect(response).to be_redirect # as it's redirected us
      expect(Paper.count).to eq(paper_count)
    end

    it "NOT LOGGED IN responds with redirect" do
      paper_params = {title: "Yeah whateva", body: "something"}
      post :create, params: {paper: paper_params}
      expect(response).to be_redirect
    end
  end

  describe "four oh four" do
    it "should 404 when passed an invalid sha" do
      get :show, params: {id: SecureRandom.hex}, format: "html"
      expect(response.body).to match /404 Not Found/
      expect(response.status).to eq(404)
    end

    it "should 404 when passed an invalid DOI" do
      get :show, params: {id: "10.21105/1234"}, format: "html"
      expect(response.body).to match /404 Not Found/
      expect(response.status).to eq(404)
    end

    it "should 404 for a paper that has been rejected" do
      rejected_paper = create(:paper, state: 'rejected')
      get :show, params: {id: rejected_paper.sha}, format: "html"
      expect(response.status).to eq(404)
    end

    it "should 404 for a paper that has just been submitted" do
      submitted_paper = create(:paper, state: 'submitted')
      get :show, params: {id: submitted_paper.sha}, format: "html"
      expect(response.status).to eq(404)
    end

    it "should be visible for a user who owns the paper" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      submitted_paper = create(:paper, state: 'submitted', submitting_author: user)

      get :show, params: {id: submitted_paper.sha}, format: "html"
      expect(response.status).to eq(200)
    end

    it "should be visible for an admin" do
      user = create(:user)
      admin = create(:user, admin: true)
      allow(controller).to receive_message_chain(:current_user).and_return(admin)
      submitted_paper = create(:paper, state: 'submitted', submitting_author: user)

      get :show, params: {id: submitted_paper.sha}, format: "html"
      expect(response.status).to eq(200)
    end
  end

  describe "paper lookup" do
    it "should return the created_at date for a paper" do
      submitted_paper = create(:paper, state: 'submitted', created_at: 3.days.ago, meta_review_issue_id: 123)

      get :lookup, params: {id: 123}
      expect(JSON.parse(response.body)['submitted']).to eq(3.days.ago.strftime('%d %B %Y'))
    end

    it "should 404 when passed an invalid id" do
      get :lookup, params: {id: 12345}

      expect(response.body).to match /404 Not Found/
      expect(response.status).to eq(404)
    end
  end

  describe "accepted papers" do
    it "should not redirect when accepting any content type" do
      paper = create(:accepted_paper)
      request.headers["HTTP_ACCEPT"] = "*/*"

      get :show, params: {doi: paper.doi}
      expect(response).to render_template("papers/show")
    end

    it "should not redirect for URLs with DOIs when asking for HTML response" do
      paper = create(:accepted_paper)

      get :show, params: {doi: paper.doi}, format: "html"
      expect(response).to render_template("papers/show")
    end

    it "should not redirect for URLs with DOIs when asking for any response" do
      paper = create(:accepted_paper)

      get :show, params: {doi: paper.doi}
      expect(response).to render_template("papers/show")
    end

    it "should redirect URLs with the paper SHA to the URL with the DOI in the path" do
      paper = create(:accepted_paper)

      get :show, params: {id: paper.sha}, format: "html"
      expect(response).to redirect_to(paper.seo_url)
    end
  end

  describe "status badges" do
    it "should return the correct status badge for a submitted paper" do
      submitted_paper = create(:paper, state: 'submitted')

      get :status, params: {id: submitted_paper.sha}, format: "svg"
      expect(response.body).to match /Submitted/
    end

    it "should return the correct status badge for an accepted paper" do
      submitted_paper = create(:accepted_paper, doi: "10.21105/jose.12345")

      get :status, params: {id: submitted_paper.sha}, format: "svg"
      expect(response.body).to match /10.21105/
    end

    it "should return the correct status badge for an unknown paper" do
      get :status, params: {id: "asdasd"}, format: "svg"
      expect(response.body).to match /Unknown/
    end
  end

  describe "GET Paper JSON" do
    it "returns valid json" do
      paper = create(:retracted_paper)
      get :show, params: {doi: paper.doi}, format: "json"
      expect(response).to be_successful
      expect(response).to render_template("papers/show")
      expect(response.media_type).to eq("application/json")
      expect { JSON.parse(response.body) }.not_to raise_error
    end

    it "returns paper's metadata" do
      paper = create(:retracted_paper, state: "superceded")
      get :show, params: {doi: paper.doi}, format: "json"
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["title"]).to eq(paper.title)
      expect(parsed_response["state"]).to eq("superceded")
      expect(parsed_response["doi"]).to be_nil
      expect(parsed_response["published_at"]).to be_nil
    end

    it "returns publication info for accepted papers" do
      user = create(:user)
      editor = create(:editor, user: user)
      paper = create(:accepted_paper, editor: editor)
      get :show, params: {doi: paper.doi}, format: "json"
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["title"]).to eq(paper.title)
      expect(parsed_response["state"]).to eq("accepted")
      expect(parsed_response["editor"]).to eq("@arfon")
      expect(parsed_response["editor_name"]).to eq("Person McEditor")
      expect(parsed_response["editor_orcid"]).to eq("0000-0000-0000-1234")
      expect(parsed_response["doi"]).to eq("10.21105/jose.00000")
      expect(parsed_response["published_at"]).to_not be_nil
    end
  end

  describe "GET Atom feeds" do
    it "returns an Atom feed for #index" do
      get :index, format: "atom"
      expect(response).to be_successful
      expect(response).to render_template("papers/index")
      expect(response.media_type).to eq("application/atom+xml")
    end

    it "returns a valid Atom feed for #popular (published)" do
      get :popular, format: "atom"
      expect(response).to be_successful
      expect(response).to render_template("papers/index")
      expect(response.media_type).to eq("application/atom+xml")
    end
  end
end

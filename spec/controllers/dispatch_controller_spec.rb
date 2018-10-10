require 'rails_helper'

def json_fixture(file_name)
  File.open('spec/fixtures/' + file_name, 'rb').read
end

describe DispatchController, :type => :controller do
  render_views

  let(:whedon_pre_review_opened) { json_fixture('whedon-pre-review-opened.json') }
  let(:whedon_pre_review_comment) { json_fixture('whedon-pre-review-comment.json') }
  let(:editor_pre_review_comment) { json_fixture('editor-pre-review-comment.json') }

  let(:whedon_review_opened) { json_fixture('whedon-review-opened.json') }
  let(:whedon_review_comment) { json_fixture('whedon-review-comment.json') }
  let(:editor_review_comment) { json_fixture('editor-review-comment.json') }
  let(:whedon_review_edit) { json_fixture('whedon-review-edit.json') }

  let(:whedon_pre_review_comment_random) { json_fixture('whedon-pre-review-comment-random-review.json') }


  describe "POST #github_recevier for PRE-REVIEW", :type => :request do
    before do
      @paper = create(:paper, :meta_review_issue_id => 78, :review_issue_id => nil)
      post '/dispatch', params: whedon_pre_review_opened, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      @paper.reload
    end

    it "should initialize the activities when an issue is opened" do
      expect(response).to be_ok
      expect(@paper.activities).to eq({"issues"=>{"commenters"=>{"pre-review"=>{}, "review"=>{}}, "comments"=>[], "last_edits"=>{}}})
    end

    it "should UPDATE the activities when an issue is then commented on" do
      post '/dispatch', params: whedon_pre_review_comment, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post '/dispatch', params: editor_pre_review_comment, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      @paper.reload

      expect(response).to be_ok
      expect(@paper.activities['issues']['commenters']).to eq({"pre-review"=>{"whedon"=>1, "editor"=>1}, "review"=>{}})
      expect(@paper.activities['issues']['comments'].length).to eq(2)

      # expect(@paper.activities['issues']['review']['commenters']).to be_empty
      # expect(@paper.activities['issues']['review']['comments'].length).to eq(0)
    end
  end

  describe "POST #github_recevier for REVIEW", :type => :request do
    before do
      @paper = create(:paper, :meta_review_issue_id => 78, :review_issue_id => 79)
      post '/dispatch', params: whedon_review_opened, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      @paper.reload
    end

    it "should initialize the activities when a review issue is opened" do
      expect(response).to be_ok
      expect(@paper.activities).to eq({"issues"=>{"commenters"=>{"pre-review"=>{}, "review"=>{}}, "comments"=>[], "last_edits"=>{}}})
    end
  end

  describe "POST #github_recevier for REVIEW", :type => :request do
    before do
      @paper = create(:paper, :meta_review_issue_id => 78, :review_issue_id => 79)
      post '/dispatch', params: whedon_review_edit, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      @paper.reload
    end

    it "should update the last_edits key" do
      expect(response).to be_ok
      expect(@paper.activities).to eq({"issues"=>{"commenters"=>{"pre-review"=>{}, "review"=>{}}, "comments"=>[], "last_edits"=>{"comment-editor"=>"2018-10-06T16:18:56Z"}}})
    end
  end

  describe "POST #github_recevier", :type => :request do
    it "shouldn't do anything if the payload is not for one of the papers" do
      random_paper = create(:paper, :meta_review_issue_id => 1234)
      post '/dispatch', params: whedon_pre_review_comment, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      random_paper.reload

      expect(response).to be_ok
      expect(random_paper.activities).to eq({})
    end

    it "shouldn't do anything if a payload is received for the wrong repository" do
      paper = create(:paper, :meta_review_issue_id => 78)
      post '/dispatch', params: whedon_pre_review_comment_random, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      paper.reload

      expect(response).to be_unprocessable
      expect(paper.activities).to eq({})
    end

    it "shouldn't care if an issue comment payload is received before the 'opened' payload" do
      paper = create(:paper, :meta_review_issue_id => 78, :review_issue_id => 79)
      post '/dispatch', params: whedon_review_comment, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      paper.reload

      expect(response).to be_ok
      expect(paper.activities['issues']['commenters']).to eq({"pre-review"=>{}, "review"=>{"whedon"=>1}})
      expect(paper.activities['issues']['comments'].length).to eq(1)
      expect(paper.activities['issues']['commenters']['reviews']).to be_nil
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

    it "with the correct API key, a single reviewer, but an invalid editor" do
      user = create(:user)
      editor = create(:editor, :login => "mouse")
      editing_user = create(:user, :editor => editor)

      paper = create(:review_pending_paper, :state => "review_pending", :meta_review_issue_id => 1234, :user_id => user.id)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      # Can't create review issue because editor is invalid
      expect {
        post :api_start_review, params: {:secret => "mooo", :id => 1234, :reviewers => "mickey", :editor => "NOTmouse"}
      }.to raise_error(AASM::InvalidTransition)

      expect(editor.papers.count).to eq(0)
    end

    it "with the correct API key and a single reviewer" do
      user = create(:user)
      editor = create(:editor, :login => "mouse")
      editing_user = create(:user, :editor => editor)

      paper = create(:review_pending_paper, :state => "review_pending", :meta_review_issue_id => 1234, :user_id => user.id)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      post :api_start_review, params: {:secret => "mooo", :id => 1234, :reviewers => "mickey", :editor => "mouse"}

      expect(response).to be_created
      expect(editor.papers.count).to eq(1)
      expect(paper.reload.reviewers).to eq(['@mickey'])
    end

    it "with the correct API key and multiple reviewers" do
      user = create(:user)
      editor = create(:editor, :login => "mouse")
      editing_user = create(:user, :editor => editor)

      paper = create(:review_pending_paper, :state => "review_pending", :meta_review_issue_id => 1234, :user_id => user.id)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      post :api_start_review, params: {:secret => "mooo", :id => 1234, :reviewers => "mickey,minnie", :editor => "mouse"}
      expect(response).to be_created
      expect(editor.papers.count).to eq(1)
      expect(paper.reload.reviewers).to eq(['@mickey', '@minnie'])
    end

    it "with the correct API key and multiple reviewers should strip whitespace" do
      user = create(:user)
      editor = create(:editor, :login => "mouse")
      editing_user = create(:user, :editor => editor)

      paper = create(:review_pending_paper, :state => "review_pending", :meta_review_issue_id => 1234, :user_id => user.id)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      post :api_start_review, params: {:secret => "mooo", :id => 1234, :reviewers => "  white   ,space   ", :editor => "mouse"}
      expect(response).to be_created
      expect(editor.papers.count).to eq(1)
      expect(paper.reload.reviewers).to eq(['@white', '@space'])
    end
  end

  describe "POST #api_assign_editor" do
    ENV["WHEDON_SECRET"] = "mooo"

    it "with no API key" do
      post :api_assign_editor
      expect(response).to be_forbidden
    end

    it "with the correct API key and valid editor" do
      editor = create(:editor, :login => "jimmy")
      paper = create(:review_pending_paper, :state => "review_pending", :meta_review_issue_id => 1234)

      post :api_assign_editor, params: {:secret => "mooo",
                                        :id => 1234,
                                        :editor => "jimmy"
                                        }

      expect(response).to be_success
      expect(paper.reload.editor).to eql(editor)
    end

    it "with the correct API key and invalid editor" do
      editor = create(:editor, :login => "jimmy")
      paper = create(:review_pending_paper, :state => "review_pending", :meta_review_issue_id => 1234)

      post :api_assign_editor, params: {:secret => "mooo",
                                        :id => 1234,
                                        :editor => "joey"
                                        }

      expect(response).to be_unprocessable
      expect(paper.reload.editor).to be_nil
    end

    it "with the correct API key and invalid paper" do
      editor = create(:editor, :login => "jimmy")
      paper = create(:review_pending_paper, :state => "review_pending", :meta_review_issue_id => 1234)

      post :api_assign_editor, params: {:secret => "mooo",
                                        :id => 12345,
                                        :editor => "jimmy"
                                        }

      expect(response).to be_unprocessable
      expect(paper.reload.editor).to be_nil
    end
  end

  describe "POST #api_assign_reviewers" do
    ENV["WHEDON_SECRET"] = "mooo"

    it "with no API key" do
      post :api_assign_reviewers
      expect(response).to be_forbidden
    end

    it "with the correct API key" do
      editor = create(:editor, :login => "jimmy")
      paper = create(:review_pending_paper, :state => "review_pending", :meta_review_issue_id => 1234)

      post :api_assign_reviewers, params: {:secret => "mooo",
                                          :id => 1234,
                                          :reviewers => "joey, dave"
                                          }

      expect(response).to be_success
      expect(paper.reload.reviewers).to eql(["@joey", "@dave"])
    end

    it "with the correct API key and invalid paper" do
      editor = create(:editor, :login => "jimmy")
      paper = create(:review_pending_paper, :state => "review_pending", :meta_review_issue_id => 1234)

      post :api_assign_reviewers, params: {:secret => "mooo",
                                          :id => 12345,
                                          :reviewers => "mike"
                                          }

      expect(response).to be_unprocessable
      expect(paper.reload.editor).to be_nil
    end
  end

  describe "POST #api_deposit" do
    ENV["WHEDON_SECRET"] = "mooo"

    it "with no API key" do
      post :api_deposit
      expect(response).to be_forbidden
    end

    it "with the correct API key" do
      user = create(:user)
      paper = create(:under_review_paper, :review_issue_id => 1234, :user_id => user.id)

      post :api_deposit, params: {:secret => "mooo",
                                  :id => 1234,
                                  :doi => "10.0001/joss.01234",
                                  :archive_doi => "10.0001/zenodo.01234",
                                  :citation_string => "Smith et al., 2008, JOSS, etc.",
                                  :authors => "Arfon Smith, Mickey Mouse",
                                  :title => "Foo, bar, baz"
                                  }
      expect(response).to be_success
      expect(paper.reload.state).to eql('accepted')
    end
  end
end

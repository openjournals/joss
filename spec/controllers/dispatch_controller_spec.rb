require 'rails_helper'

def json_fixture(file_name)
  File.open('spec/fixtures/' + file_name, 'rb').read
end

def set_signature(payload)
  'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['GH_SECRET'], payload)
end

def headers(event, payload)
  {
    'CONTENT_TYPE' => 'application/json',
    'ACCEPT' => 'application/json',
    'HTTP_X_GITHUB_EVENT' => event.to_s,
    'HTTP_X_HUB_SIGNATURE' => set_signature(payload)
  }
end

describe DispatchController, type: :controller do
  render_views

  let(:whedon_pre_review_opened) { json_fixture('whedon-pre-review-opened.json') }
  let(:whedon_pre_review_comment) { json_fixture('whedon-pre-review-comment.json') }
  let(:editor_pre_review_comment) { json_fixture('editor-pre-review-comment.json') }

  let(:whedon_review_opened) { json_fixture('whedon-review-opened.json') }
  let(:whedon_review_comment) { json_fixture('whedon-review-comment.json') }
  let(:editor_review_comment) { json_fixture('editor-review-comment.json') }
  let(:whedon_review_edit) { json_fixture('whedon-review-edit.json') }

  let(:whedon_review_labeled) { json_fixture('whedon-review-labeled.json') }

  let(:whedon_pre_review_comment_random) { json_fixture('whedon-pre-review-comment-random-review.json') }

  describe "POST #github_receiver for REVIEW with invalid HTTP_X_HUB_SIGNATURE", type: :request do
    before do
      wrong_payload = "foobarbaz"
      @paper = create(:paper, meta_review_issue_id: 78, review_issue_id: 79)
      post '/dispatch', params: whedon_review_opened, headers: headers(:issues, wrong_payload)
      @paper.reload
    end

    it "should detect invalid signature" do
      expect(response).to be_forbidden
      expect(response.headers['Msg']).to eq("Signatures didn't match!")
      expect(@paper.activities).to eq({})
    end
  end

  describe "POST #github_receiver for PRE-REVIEW", type: :request do
    before do
      @paper = create(:paper, meta_review_issue_id: 78, review_issue_id: nil)
      post '/dispatch', params: whedon_pre_review_opened, headers: headers(:issues, whedon_pre_review_opened)
      @paper.reload
    end

    it "should initialize the activities when an issue is opened" do
      expect(response).to be_ok
      expect(@paper.activities).to eq({"issues"=>{"commenters"=>{"pre-review"=>{}, "review"=>{}}, "comments"=>[], "last_edits"=>{}, "last_comments" => {}}})
    end

    it "should UPDATE the activities when an issue is then commented on" do
      post '/dispatch', params: whedon_pre_review_comment, headers: headers(:issue_comment, whedon_pre_review_comment)
      post '/dispatch', params: editor_pre_review_comment, headers: headers(:issue_comment, editor_pre_review_comment)
      @paper.reload

      expect(response).to be_ok
      expect(@paper.activities['issues']['commenters']).to eq({"pre-review"=>{"whedon"=>1, "editor"=>1}, "review"=>{}})
      expect(@paper.activities['issues']['comments'].length).to eq(2)
      expect(@paper.activities['issues']['last_comments']['editor']).to eq("2018-09-30T11:48:30Z")
      expect(@paper.activities['issues']['last_comments']['whedon']).to eq("2018-09-30T11:48:40Z")
    end
  end

  describe "POST #github_receiver for REVIEW with labeling event", type: :request do
    before do
      @paper = create(:paper, meta_review_issue_id: 78, review_issue_id: 79, labels: [{ "foo" => "efefef" }])
      post '/dispatch', params: whedon_review_labeled, headers: headers(:issues, whedon_review_labeled)
      @paper.reload
    end

    it "should update the labels on the paper" do
      expect(response).to be_ok
      expect(@paper.labels).to eq({ "accepted" => "0052cc" })
    end
  end

  describe "POST #github_receiver for REVIEW when a paper doesn't have a suggested_editor set", type: :request do
    before do
      build(:paper, meta_review_issue_id: 78, suggested_editor: nil, review_issue_id: 79, labels: [{ "foo" => "efefef" }]).save(validate: false)
      @paper = Paper.find_by_meta_review_issue_id(78)

      post '/dispatch', params: whedon_review_labeled, headers: headers(:issues, whedon_review_labeled)
      @paper.reload
    end

    it "should update the labels on the paper" do
      expect(response).to be_ok
      expect(@paper.labels).to eq({ "accepted" => "0052cc" })
    end
  end

  describe "POST #github_receiver for REVIEW - open", type: :request, vcr: true do
    before do
      @paper = create(:paper, meta_review_issue_id: 78, review_issue_id: 79)
      post '/dispatch', params: whedon_review_opened, headers: headers(:issues, whedon_review_opened)
      @paper.reload
    end

    it "should initialize the activities when a review issue is opened" do
      expect(response).to be_ok
      expect(@paper.activities).to eq({"issues"=>{"commenters"=>{"pre-review"=>{}, "review"=>{}}, "comments"=>[], "last_edits"=>{}, "last_comments" => {}}})
    end
  end

  describe "POST #github_receiver for REVIEW", type: :request, vcr: true do
    before do
      @paper = create(:paper, meta_review_issue_id: 78, review_issue_id: 79)
      post '/dispatch', params: whedon_review_edit, headers: headers(:issues, whedon_review_edit)
      @paper.reload
    end

    it "should update the last_edits key" do
      expect(response).to be_ok
      expect(@paper.activities).to eq({"issues"=>{"commenters"=>{"pre-review"=>{}, "review"=>{}}, "comments"=>[], "last_comments" => {}, "last_edits"=>{"comment-editor"=>"2018-10-06T16:18:56Z"}}})
    end

    it "should update the percent_complete value" do
      expect(@paper.percent_complete).to eq(0.9375)
    end

    it "should update the last_activity field" do
      github_updated_at = JSON.parse(whedon_review_edit)['issue']['updated_at'].to_datetime.strftime("%Y-%m-%dT%l:%M:%S%z")
      expect(@paper.last_activity.strftime('%Y-%m-%dT%l:%M:%S%z')).to eql(github_updated_at)
    end
  end

  describe "POST #github_receiver", type: :request do
    it "shouldn't do anything if the payload is not for one of the papers" do
      random_paper = create(:paper, meta_review_issue_id: 1234)
      post '/dispatch', params: whedon_pre_review_comment, headers: headers(:issue_comment, whedon_pre_review_comment)
      random_paper.reload

      expect(response).to be_ok
      expect(random_paper.activities).to eq({})
    end

    it "shouldn't do anything if a payload is received for the wrong repository" do
      paper = create(:paper, meta_review_issue_id: 78)
      post '/dispatch', params: whedon_pre_review_comment_random, headers: headers(:issue_comment, whedon_pre_review_comment_random)
      paper.reload

      expect(response).to be_forbidden
      expect(response.headers['Msg']).to eq("Event origin not allowed")
      expect(paper.activities).to eq({})
    end

    it "shouldn't care if an issue comment payload is received before the 'opened' payload" do
      signature = set_signature(whedon_review_comment)

      paper = create(:paper, meta_review_issue_id: 78, review_issue_id: 79)
      post '/dispatch', params: whedon_review_comment, headers: headers(:issue_comment, whedon_review_comment)
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
      post :api_start_review, params: {secret: "fooo"}
      expect(response).to be_forbidden
    end

    it "with the correct API key, a single reviewer, but an invalid editor" do
      user = create(:user)
      editor = create(:editor, login: "mouse")
      editing_user = create(:user, editor: editor)

      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234, user_id: user.id)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      # Can't create review issue because editor is invalid
      expect {
        post :api_start_review, params: {secret: "mooo", id: 1234, reviewers: "mickey", editor: "NOTmouse"}
      }.to raise_error(AASM::InvalidTransition)

      expect(editor.papers.count).to eq(0)
    end

    it "with the correct API key and a single reviewer" do
      user = create(:user)
      editor = create(:editor, login: "mouse")
      editing_user = create(:user, editor: editor)

      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234, user_id: user.id)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      post :api_start_review, params: {secret: "mooo", id: 1234, reviewers: "mickey", editor: "mouse"}

      expect(response).to be_created
      expect(editor.papers.count).to eq(1)
      expect(paper.reload.reviewers).to eq(['@mickey'])
    end

    it "with the correct API key and multiple reviewers" do
      user = create(:user)
      editor = create(:editor, login: "mouse")
      editing_user = create(:user, editor: editor)

      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234, user_id: user.id)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      post :api_start_review, params: {secret: "mooo", id: 1234, reviewers: "mickey,minnie", editor: "mouse"}
      expect(response).to be_created
      expect(editor.papers.count).to eq(1)
      expect(paper.reload.reviewers).to eq(['@mickey', '@minnie'])
    end

    it "with the correct API key and multiple reviewers should strip whitespace" do
      user = create(:user)
      editor = create(:editor, login: "mouse")
      editing_user = create(:user, editor: editor)

      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234, user_id: user.id)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      post :api_start_review, params: {secret: "mooo", id: 1234, reviewers: "  white   ,space   ", editor: "mouse"}
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
      editor = create(:editor, login: "jimmy")
      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234)

      post :api_assign_editor, params: {secret: "mooo",
                                        id: 1234,
                                        editor: "jimmy"
                                        }

      expect(response).to be_successful
      expect(paper.reload.editor).to eql(editor)
    end

    it "with the correct API key and invalid editor" do
      editor = create(:editor, login: "jimmy")
      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234)

      post :api_assign_editor, params: {secret: "mooo",
                                        id: 1234,
                                        editor: "joey"
                                        }

      expect(response).to be_unprocessable
      expect(paper.reload.editor).to be_nil
    end

    it "with the correct API key and invalid paper" do
      editor = create(:editor, login: "jimmy")
      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234)

      post :api_assign_editor, params: {secret: "mooo",
                                        id: 12345,
                                        editor: "jimmy"
                                        }

      expect(response).to be_unprocessable
      expect(paper.reload.editor).to be_nil
    end
  end

  describe "POST #api_editor_invite" do
    ENV["WHEDON_SECRET"] = "mooo"

    it "with no API key" do
      post :api_editor_invite
      expect(response).to be_forbidden
    end

    it "with the correct API key and valid editor" do
      editor = create(:editor, login: "jimmy")
      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234)
      post_params = { secret: "mooo", id: 1234, editor: "jimmy" }

      expect { post :api_editor_invite, params: post_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect { post :api_editor_invite, params: post_params }.to change { editor.invitations.count }.by(1)
      expect { post :api_editor_invite, params: post_params }.to change { paper.invitations.count }.by(1)
    end

    it "with the correct API key and invalid editor" do
      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234)
      post_params = { secret: "mooo", id: 1234, editor: "not-editor" }
      post :api_editor_invite, params: post_params

      expect(response).to be_unprocessable
    end
  end

  describe "POST #api_assign_reviewers" do
    ENV["WHEDON_SECRET"] = "mooo"

    it "with no API key" do
      post :api_assign_reviewers
      expect(response).to be_forbidden
    end

    it "with the correct API key" do
      editor = create(:editor, login: "jimmy")
      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234)

      post :api_assign_reviewers, params: {secret: "mooo",
                                          id: 1234,
                                          reviewers: "joey, dave"
                                          }

      expect(response).to be_successful
      expect(paper.reload.reviewers).to eql(["@joey", "@dave"])
    end

    it "with the correct API key and invalid paper" do
      editor = create(:editor, login: "jimmy")
      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234)

      post :api_assign_reviewers, params: {secret: "mooo",
                                          id: 12345,
                                          reviewers: "mike"
                                          }

      expect(response).to be_unprocessable
      expect(paper.reload.editor).to be_nil
    end
  end

  describe "PUT #api_reject" do
    ENV["WHEDON_SECRET"] = "mooo"

    it "with no API key" do
      post :api_reject
      expect(response).to be_forbidden
    end

    it "with the correct API key for a review_pending paper" do
      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234)

      post :api_reject, params: { secret: "mooo",
                                  id: 1234}

      expect(response).to be_successful
      expect(paper.reload.state).to eql("rejected")
    end

    it "with the correct API key for rejected paper" do
      paper = create(:rejected_paper, meta_review_issue_id: 1234)

      post :api_reject, params: { secret: "mooo",
                                  id: 1234}

      expect(response).to be_successful
      expect(paper.reload.state).to eql("rejected")
    end
  end

  describe "PUT #api_withdraw" do
    ENV["WHEDON_SECRET"] = "mooo"

    it "with no API key" do
      post :api_withdraw
      expect(response).to be_forbidden
    end

    it "with the correct API key for a review_pending paper" do
      paper = create(:review_pending_paper, state: "review_pending", meta_review_issue_id: 1234)

      post :api_withdraw, params: { secret: "mooo",
                                  id: 1234}

      expect(response).to be_successful
      expect(paper.reload.state).to eql("withdrawn")
    end

    it "with the correct API key for rejected paper" do
      paper = create(:rejected_paper, meta_review_issue_id: 1234)

      post :api_withdraw, params: { secret: "mooo",
                                  id: 1234}

      expect(response).to be_successful
      expect(paper.reload.state).to eql("withdrawn")
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
      paper = create(:under_review_paper, review_issue_id: 1234, user_id: user.id)
      encoded_metadata = "eyJwYXBlciI6eyJ0aXRsZSI6IkZpZGdpdDogQW4gdW5nb2RseSB1bmlvbiBv\nZiBHaXRIdWIgYW5kIGZpZ3NoYXJlIiwidGFncyI6WyJleGFtcGxlIiwidGFn\ncyIsImZvciB0aGUgcGFwZXIiXSwibGFuZ3VhZ2VzIjpbIlB5dGhvbiIsIlJ1\nc3QiLCJQZXJsIl0sImF1dGhvcnMiOlt7ImdpdmVuX25hbWUiOiJBcmZvbiIs\nIm1pZGRsZV9uYW1lIjoiTS4iLCJsYXN0X25hbWUiOiJTbWl0aCIsIm9yY2lk\nIjoiMDAwMC0wMDAyLTM5NTctMjQ3NCIsImFmZmlsaWF0aW9uIjoiR2l0SHVi\nIEluYy4sIERpc25leSBJbmMuIn0seyJnaXZlbl9uYW1lIjoiSmFtZXMiLCJt\naWRkbGVfbmFtZSI6IlAuIiwibGFzdF9uYW1lIjoidmFuIERpc2hvZWNrIiwi\nb3JjaWQiOiIwMDAwLTAwMDItMzk1Ny0yNDc0IiwiYWZmaWxpYXRpb24iOiJE\naXNuZXkgSW5jLiJ9XSwiZG9pIjoiMTAuMjExMDUvam9zcy4wMDAxNyIsImFy\nY2hpdmVfZG9pIjoiaHR0cDovL2R4LmRvaS5vcmcvMTAuNTI4MS96ZW5vZG8u\nMTM3NTAiLCJyZXBvc2l0b3J5X2FkZHJlc3MiOiJodHRwczovL2dpdGh1Yi5j\nb20vYXBwbGljYXRpb25za2VsZXRvbi9Ta2VsZXRvbiIsImVkaXRvciI6ImFy\nZm9uIiwicmV2aWV3ZXJzIjpbIkBqaW0iLCJAYm9iIl19fQ==\n"

      post :api_deposit, params: {secret: "mooo",
                                  id: 1234,
                                  doi: "10.0001/joss.01234",
                                  archive_doi: "10.0001/zenodo.01234",
                                  citation_string: "Smith et al., 2008, JOSS, etc.",
                                  authors: "Arfon Smith, Mickey Mouse",
                                  title: "Foo, bar, baz",
                                  metadata: encoded_metadata
                                  }
      expect(response).to be_successful
      expect(paper.reload.state).to eql('accepted')
      expect(paper.metadata['paper']['reviewers']).to eql(["@jim", "@bob"])
    end
  end
end

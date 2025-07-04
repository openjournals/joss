require 'rails_helper'

describe Paper do
  before(:each) do
    skip_paper_repo_url_check
    Paper.destroy_all
  end

  it "should know how to validate a Git repository address" do
    paper = build(:paper, :repository_url => 'https://example.com')
    expect { paper.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "belongs to the submitting author" do
    association = Paper.reflect_on_association(:submitting_author)
    expect(association.macro).to eq(:belongs_to)
  end

  it "belongs to a track" do
    association = Paper.reflect_on_association(:track)
    expect(association.macro).to eq(:belongs_to)
  end

  it "retraction paper belongs to a retracted paper" do
    association = Paper.reflect_on_association(:retracted_paper)
    expect(association.macro).to eq(:belongs_to)

    association = Paper.reflect_on_association(:retraction_paper)
    expect(association.macro).to eq(:has_one)
  end

  it "has many invitations" do
    association = Paper.reflect_on_association(:invitations)
    expect(association.macro).to eq(:has_many)
  end

  it "should know how to parameterize itself properly" do
    paper = create(:paper)

    expect(paper.sha).to eq(paper.to_param)
  end

  it "should return it's submitting_author" do
    user = create(:user)
    paper = create(:paper, user_id: user.id)

    expect(paper.submitting_author).to eq(user)
  end

  it "should have a complete value for repository url" do
    params = { title: 'Test paper',
               body: 'A test paper description',
               repository_url: 'github.com/arfon/fidgit',
               software_version: 'v1.0.0',
               submitting_author: create(:user),
               submission_kind: 'new',
               track: create(:track) }

    paper = Paper.create(params)
    expect(paper).to_not be_valid
    expect(paper.errors.messages[:repository_url].first).to eq("Repository URL is missing the protocol segment (http/https)")

    paper = Paper.create(params.merge(repository_url: 'http://github.com/arfon/fidgit'))
    expect(paper).to be_valid
  end

  it "must have a track assigned on creation if tracks are enabled" do
    enable_feature(:tracks) do
      no_track_params = { title: 'Test paper',
                          body: 'A test paper description',
                          repository_url: 'http://github.com/arfon/fidgit',
                          software_version: 'v1.0.0',
                          submitting_author: create(:user),
                          submission_kind: 'new' }

      valid_params = no_track_params.merge track: create(:track)

      paper = Paper.create(no_track_params)
      expect(paper).to_not be_valid
      expect(paper.errors.full_messages.first).to eq("Track You must select a valid subject for the paper")

      paper = Paper.create(valid_params)
      expect(paper).to be_valid
    end
  end

  it "does not have a track assigned on creation if tracks are disabled" do
    disable_feature(:tracks) do
      no_track_params = { title: 'Test paper',
                         body: 'A test paper description',
                         repository_url: 'http://github.com/arfon/fidgit',
                         software_version: 'v1.0.0',
                         submitting_author: create(:user),
                         submission_kind: 'new' }

      paper = Paper.create(no_track_params)
      expect(paper).to be_valid
    end
  end

  describe "Scopes" do
    it "should return recent" do
      old_paper = create(:paper, created_at: 2.weeks.ago)
      new_paper = create(:paper)

      expect(Paper.recent).to eq([new_paper])
    end

    it "should return only visible papers" do
      hidden_paper = create(:paper, state: "submitted")
      visible_paper_1 = create(:accepted_paper)
      visible_paper_2 = create(:paper, state: "superceded")

      expect(Paper.visible).to contain_exactly(visible_paper_1, visible_paper_2)
      assert hidden_paper.invisible?
    end

    it "should exclude withdrawn and rejected papers" do
      rejected_paper = create(:paper, state: "rejected")
      withdrawn_paper = create(:paper, state: "withdrawn")
      paper = create(:accepted_paper)

      expect(Paper.everything).to contain_exactly(paper)
      expect(Paper.invisible).to contain_exactly(rejected_paper, withdrawn_paper)
    end

    it "should filter by track" do
      track_A, track_B = create_list(:track, 2)
      paper_A1, paper_A2 = create_list(:paper, 2, track: track_A)
      paper_B1, paper_B2 = create_list(:paper, 2, track: track_B)
      paper_C = create(:paper)

      track_A_papers = Paper.by_track(track_A.id)
      expect(track_A_papers.size).to eq(2)
      expect(track_A_papers.include?(paper_A1)).to be true
      expect(track_A_papers.include?(paper_A2)).to be true
    end

    it "should find query scoped papers" do
      paper_1, paper_2, paper_3, paper_4, paper_5 = create_list(:paper, 5)
      paper_2.update labels: {"query-scope" => "FF0000"}
      paper_4.update labels: {"query-scope" => "CC00CC"}

      query_scoped_papers = Paper.query_scoped
      expect(query_scoped_papers.size).to eq(2)
      expect(query_scoped_papers.include?(paper_2)).to be true
      expect(query_scoped_papers.include?(paper_4)).to be true
    end
  end

  # GitHub stuff
  it "should know how to return a pretty repo name with owner" do
    paper = create(:paper, repository_url: "https://github.com/openjournals/joss-reviews")

    expect(paper.pretty_repository_name).to eq("openjournals / joss-reviews")
  end

  it 'should know how to return the archive DOI with a full URL' do
    paper = create(:paper, archive_doi: '10.6084/m9.figshare.828487')

    expect(paper.archive_doi_url).to eq('https://doi.org/10.6084/m9.figshare.828487')
  end

  it "should bail creating a full archive DOI URL if if can't figure out what to do" do
    paper = create(:paper, archive_doi: "http://foobar.com")

    expect(paper.archive_doi_url).to eq("http://foobar.com")
  end

  it "should know how to generate its review url" do
    paper = create(:paper, review_issue_id: 999)

    expect(paper.review_url).to eq("https://github.com/#{Rails.application.settings["reviews"]}/issues/999")
  end

  describe "#set_track_id" do
    it "should update paper's track_id" do
      track1 = create(:track)
      paper = create(:paper, track: track1)
      track2 = create(:track)

      expect(paper.track).to eq(track1)
      paper.set_track_id track2.id
      expect(paper.reload.track).to eq(track2)
    end
  end

  describe "#set_editor" do
    it "should update paper's editor" do
      paper = create(:paper)
      editor = create(:editor)

      paper.set_editor editor
      expect(paper.editor).to eq(editor)
    end

    it "should mark editor's pending invitation as accepted" do
      paper = create(:paper)
      editor = create(:editor)
      invitation = create(:invitation, :pending, paper: paper, editor: editor)

      paper.set_editor editor
      expect(invitation.reload).to be_accepted
    end

    it "should expire other editor's pending invitations" do
      paper = create(:paper)
      editor = create(:editor)
      invitation_1 = create(:invitation, :pending, paper: paper)
      invitation_2 = create(:invitation, :pending, paper: paper)

      paper.set_editor editor
      expect(invitation_1.reload).to be_expired
      expect(invitation_2.reload).to be_expired
    end
  end

  describe "#invite_editor" do
    it "should return false if editor does not exist" do
      expect(create(:paper).invite_editor("invalid")).to be false
    end

    it "should email an invitation to the editor" do
      paper = create(:paper)
      editor = create(:editor)

      expect { paper.invite_editor(editor.login) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should create a pending invitation for the invited editor" do
      paper = create(:paper)
      editor = create(:editor)

      expect(Invitation.exists?(paper: paper, editor:editor)).to be_falsy
      expect { paper.invite_editor(editor.login)}.to change { Invitation.count }.by(1)
      expect(Invitation.pending.exists?(paper: paper, editor:editor)).to be_truthy
    end
  end

  describe "#is_a_retraction_notice?" do
    it "should return true if paper is a retraction notice for another paper" do
      retracted_paper = create(:paper)
      paper = create(:paper, retracted_paper: retracted_paper)

      expect(paper.retraction_for_id).to eq(retracted_paper.id)
      expect(paper.retracted_paper).to eq(retracted_paper)
      expect(paper.is_a_retraction_notice?).to be true
    end

    it "should return false oherwise" do
      paper = create(:paper)

      expect(paper.retraction_for_id).to be_nil
      expect(paper.retracted_paper).to be_nil
      expect(paper.is_a_retraction_notice?).to be false
    end
  end

  context "when accepted" do
    it "should know how to generate a PDF URL for Google Scholar" do
      paper = create(:accepted_paper)

      expect(paper.seo_url).to eq('http://joss.theoj.org/papers/10.21105/joss.00000')
      expect(paper.seo_pdf_url).to eq('http://joss.theoj.org/papers/10.21105/joss.00000.pdf')
    end
  end

  context "when not yet accepted" do
    it "should know how to generate a PDF URL for Google Scholar" do
      paper = create(:under_review_paper)

      expect(paper.seo_url).to eq('http://joss.theoj.org/papers/48d24b0158528e85ac7706aecd8cddc4')
      expect(paper.seo_pdf_url).to eq('http://joss.theoj.org/papers/48d24b0158528e85ac7706aecd8cddc4.pdf')
    end
  end

  context "when rejected" do
    it "should change the paper state" do
      paper = create(:paper, state: "submitted")
      paper.reject!

      expect(paper.state).to eq('rejected')
    end

    it "should expire all pending invitations" do
      paper = create(:paper, state: "submitted")
      invitation_1 = create(:invitation, :pending, paper: paper)
      invitation_2 = create(:invitation, :pending, paper: paper)

      paper.reject!

      expect(invitation_1.reload).to be_expired
      expect(invitation_2.reload).to be_expired
      expect(paper.state).to eq('rejected')
    end
  end

  context "when starting meta-review" do
    it "should change the paper state to review_pending" do
      editor = create(:editor, login: "arfon")
      user = create(:user, editor: editor)
      submitting_author = create(:user)

      paper = create(:submitted_paper_with_sha, submitting_author: submitting_author)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      paper.start_meta_review!('arfon', editor, paper.track_id)
      expect(paper.state).to eq('review_pending')
      expect(paper.reload.editor).to be(nil)
      expect(paper.reload.eic).to eq(editor)
    end

    it "should allow to change paper's track" do
      editor = create(:editor, login: "arfon")
      user = create(:user, editor: editor)
      submitting_author = create(:user)
      track1 = create(:track)
      track2 = create(:track)

      paper = create(:submitted_paper_with_sha, submitting_author: submitting_author, track: track1)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      expect(paper.track).to eq(track1)
      paper.start_meta_review!('arfon', editor, track2.id)
      expect(paper.state).to eq('review_pending')
      expect(paper.reload.track).to eq(track2)
    end

    it "should label GH issue with track label if tracks are enabled" do
      enable_feature(:tracks) do
        editor = create(:editor, login: "arfon")
        user = create(:user, editor: editor)
        submitting_author = create(:user)

        paper = create(:submitted_paper_with_sha, submitting_author: submitting_author)
        fake_issue = Object.new
        allow(fake_issue).to receive(:number).and_return(1)

        track = create(:track)
        expected_labels = { labels: "pre-review,#{track.label}" }
        expect(GITHUB).to receive(:create_issue).with(anything, anything, anything, expected_labels).and_return(fake_issue)

        paper.start_meta_review!('arfon', editor, track.id)
      end
    end

    it "should not label GH issue with track label if tracks are disabled" do
      disable_feature(:tracks) do
        editor = create(:editor, login: "arfon")
        user = create(:user, editor: editor)
        submitting_author = create(:user)

        paper = create(:submitted_paper_with_sha, submitting_author: submitting_author)
        fake_issue = Object.new
        allow(fake_issue).to receive(:number).and_return(1)

        expected_labels = { labels: "pre-review" }
        expect(GITHUB).to receive(:create_issue).with(anything, anything, anything, expected_labels).and_return(fake_issue)

        paper.start_meta_review!('arfon', editor)
      end
    end
  end

  context "when starting review" do
    it "should allow for the paper to be moved into the under_review state" do
      editor = create(:editor, login: "arfoneditor")
      user = create(:user, editor: editor)
      submitting_author = create(:user)
      paper = create(:review_pending_paper, submitting_author: submitting_author)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      paper.start_review('arfoneditor', 'bobthereviewer')
      expect(paper.state).to eq('under_review')
      expect(paper.editor).to eq(editor)
    end
  end

  it "should email the editor AND submitting author when submitted" do
    paper = build(:paper)

    expect {paper.save}.to change { ActionMailer::Base.deliveries.count }.by(2)
  end

  it "should be able to be withdrawn at any time" do
    paper = create(:accepted_paper)
    assert Paper.visible.include?(paper)

    paper.withdraw!
    refute Paper.visible.include?(paper)
  end

  describe "#review_body" do
    let(:author) { create(:user) }
    let(:paper) do
      instance = build(:paper, user_id: author.id, kind: kind)
      instance.save(validate: false)
      instance
    end
    let(:kind) { nil }
    subject { paper.review_body("editor_name", "mickey,mouse") }

    it { is_expected.to match /Reviewers:/ }
    it { is_expected.to match /\/papers\/#{paper.sha}/ }
    it { is_expected.to match /#{paper.repository_url}/ }
  end

  describe "#meta_review_body" do
    let(:author) { create(:user) }

    let(:paper) do
      instance = build(:paper_with_sha, user_id: author.id)
      instance.save(validate: false)
      instance
    end

    subject { paper.meta_review_body(editor, 'Important Editor') }

    context "with an editor" do
      let(:editor) { "@joss_editor" }

      it "renders text" do
        is_expected.to match /#{paper.submitting_author.github_username}/
        is_expected.to match /#{paper.submitting_author.name}/
        is_expected.to match /#{Rails.application.settings['reviewers_lookup_url']}/
        is_expected.to match /Important Editor/
      end

      it { is_expected.to match "The AEiC suggestion for the handling editor is @joss_editor" }
    end

    context "with no editor" do
      let(:editor) { "" }

      it "renders text" do
        is_expected.to match /#{paper.submitting_author.github_username}/
        is_expected.to match /#{paper.submitting_author.name}/
        is_expected.to match /#{Rails.application.settings['reviewers_lookup_url']}/
      end

      it { is_expected.to match "Currently, there isn't a JOSS editor assigned" }
    end
  end

  describe "#move_to_track" do
    before do
      @track_1 = create(:track, name: "Astronomy", short_name: "ASTRO", code: "32")
      @track_2 = create(:track, name: "Biology", short_name: "BIO", code: "33")
      @paper = create(:paper, track_id: @track_1.id)
    end

    it "should receive a new track to assign" do
      expect(@paper).to_not receive(:track)
      expect(@paper).to_not receive(:set_track_id)
      @paper.move_to_track(nil)
    end

    it "should not send an email if the track does not change" do
      expect { @paper.move_to_track(@track_1) }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "should send an email if the track does change" do
      expect { @paper.move_to_track(@track_2) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
    
    it "should do nothing if track does not change" do
      expect(@paper).to_not receive(:set_track_id)
      expect_any_instance_of(Octokit::Client).to_not receive(:remove_label)
      expect_any_instance_of(Octokit::Client).to_not receive(:add_labels_to_an_issue)
      @paper.move_to_track(@track_1)
    end

    it "should update paper's track" do
      allow_any_instance_of(Octokit::Client).to receive(:remove_label)
      allow_any_instance_of(Octokit::Client).to receive(:add_labels_to_an_issue)

      expect(@paper.track).to eq(@track_1)
      @paper.move_to_track(@track_2)
      expect(@paper.reload.track).to eq(@track_2)
    end

    it "should change labels if issues exist" do
      @paper.meta_review_issue_id = 3333
      @paper.review_issue_id = 4444

      expect_any_instance_of(Octokit::Client).to receive(:remove_label).with(anything, 3333, @track_1.label)
      expect_any_instance_of(Octokit::Client).to receive(:add_labels_to_an_issue).with(anything, 3333, [@track_2.label])
      expect_any_instance_of(Octokit::Client).to receive(:remove_label).with(anything, 4444, @track_1.label)
      expect_any_instance_of(Octokit::Client).to receive(:add_labels_to_an_issue).with(anything, 4444, [@track_2.label])

      @paper.move_to_track(@track_2)
    end

    it "should not change labels if no issues created" do
      @paper.meta_review_issue_id = nil
      @paper.review_issue_id = nil
      expect_any_instance_of(Octokit::Client).to_not receive(:remove_label)
      expect_any_instance_of(Octokit::Client).to_not receive(:add_labels_to_an_issue)

      expect(@paper.track).to eq(@track_1)
      @paper.move_to_track(@track_2)
      expect(@paper.reload.track).to eq(@track_2)
    end
  end

  describe "#bibtex_authors" do
    it "should format author names correctly for BibTeX" do
      paper = create(:accepted_paper)
      paper.metadata['paper']['authors'] = [
        {'given_name' => 'Rhoslyn', 'last_name' => 'Roebuck Williams'},
        {'given_name' => 'Harry', 'middle_name' => 'J.', 'last_name' => 'Stroud'},
        {'given_name' => 'Ludwig', 'last_name' => 'van Beethoven'}
      ]
      paper.save!

      expected_bibtex = "Roebuck Williams, Rhoslyn and Stroud, Harry J. and van Beethoven, Ludwig"
      expect(paper.bibtex_authors).to eq(expected_bibtex)
    end

    it "should handle authors with no given name" do
      paper = create(:accepted_paper)
      paper.metadata['paper']['authors'] = [
        {'given_name' => 'John', 'last_name' => 'Smith'},
        {'last_name' => 'Collective'}
      ]
      paper.save!

      expected_bibtex = "Smith, John and Collective"
      expect(paper.bibtex_authors).to eq(expected_bibtex)
    end

    it "should handle authors with only middle name" do
      paper = create(:accepted_paper)
      paper.metadata['paper']['authors'] = [
        {'middle_name' => 'J.', 'last_name' => 'Smith'}
      ]
      paper.save!

      expected_bibtex = "Smith, J."
      expect(paper.bibtex_authors).to eq(expected_bibtex)
    end
  end
end

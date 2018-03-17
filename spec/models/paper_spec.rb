require 'rails_helper'

describe Paper do
  before(:each) do
    Paper.destroy_all
  end

  it "belongs to the submitting author" do
    association = Paper.reflect_on_association(:submitting_author)
    expect(association.macro).to eq(:belongs_to)
  end

  it "should know how to parameterize itself properly" do
    paper = create(:paper)

    expect(paper.sha).to eq(paper.to_param)
  end

  it "should return it's submitting_author" do
    user = create(:user)
    paper = create(:paper, :user_id => user.id)

    expect(paper.submitting_author).to eq(user)
  end

  # Scopes

  it "should return recent" do
    old_paper = create(:paper, :created_at => 2.weeks.ago)
    new_paper = create(:paper)

    expect(Paper.recent).to eq([new_paper])
  end

  it "should return only visible papers" do
    hidden_paper = create(:paper, :state => "submitted")
    visible_paper_1 = create(:paper, :state => "accepted")
    visible_paper_2 = create(:paper, :state => "superceded")

    expect(Paper.visible).to contain_exactly(visible_paper_1, visible_paper_2)
  end

  it "should exclude withdrawn and rejected papers" do
    rejected_paper = create(:paper, :state => "rejected")
    withdrawn_paper = create(:paper, :state => "withdrawn")
    paper = create(:paper, :state => "accepted")

    expect(Paper.everything).to contain_exactly(paper)
  end

  # GitHub stuff
  it "should know how to return a pretty repo name with owner" do
    paper = create(:paper, :repository_url => "https://github.com/arfon/joss-reviews")

    expect(paper.pretty_repository_name).to eq("arfon / joss-reviews")
  end

  it 'should know how to return a pretty DOI' do
    paper = create(:paper, archive_doi: 'https://doi.org/10.6084/m9.figshare.828487')

    expect(paper.pretty_doi).to eq("10.6084/m9.figshare.828487")
  end

  it 'should know how to return a DOI with a full URL' do
    paper = create(:paper, archive_doi: '10.6084/m9.figshare.828487')

    expect(paper.doi_with_url).to eq('https://doi.org/10.6084/m9.figshare.828487')
  end

  it "should bail creating a full DOI URL if if can't figure out what to do" do
    paper = create(:paper, :archive_doi => "http://foobar.com")

    expect(paper.doi_with_url).to eq("http://foobar.com")
  end

  it "should know how to generate its review url" do
    paper = create(:paper, :review_issue_id => 999)

    expect(paper.review_url).to eq("https://github.com/#{Rails.application.settings["reviews"]}/issues/999")
  end

  context "when rejected" do
    it "should change the paper state" do
      paper = create(:paper, :state => "submitted")
      paper.reject!

      expect(paper.state).to eq('rejected')
    end
  end

  context "when starting review" do
    let(:user) { create(:user) }

    it "should initially change the paper state to review_pending" do
      paper = create(:submitted_paper_with_sha, :submitting_author => user)
      allow(paper).to receive(:create_meta_review_issue) { true }

      paper.start_meta_review(nil, 'arfon')
      expect(paper.state).to eq('review_pending')
    end

    it "should then allow for the paper to be moved into the under_review state" do
      paper = create(:review_pending_paper, :submitting_author => user)
      allow(paper).to receive(:create_review_issue) { true }

      paper.start_review(nil, 'arfoneditor', 'bobthereviewer')
      expect(paper.state).to eq('under_review')
    end
  end

  it "should email the editor when submitted" do
    paper = build(:paper)

    expect {paper.save}.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it "should be able to be withdrawn at any time" do
    paper = create(:paper, :state => "accepted")
    assert Paper.visible.include?(paper)

    paper.withdraw!
    refute Paper.visible.include?(paper)
  end

  describe "#review_body with a single author" do
    let(:author) { create(:user) }
    let(:paper) do
      instance = build(:paper, user_id: author.id, kind: kind)
      instance.save(validate: false)
      instance
    end
    subject { paper.review_body("editor_name", "reviewer_name") }

    context "with a paper type" do
      let(:kind) { "something_else" }

      it "renders the type-specific checklist" do
        expect {
          subject
        }.to raise_error(
          ActionView::Template::Error,
          %r(Missing partial content/github/_something_else_review_checklist)
        )
      end
    end

    context "with no paper type" do
      let(:kind) { nil }
      it { is_expected.to match /Reviewer:/ }
      it { is_expected.to match /JOSS conflict of interest policy/ }
      it { is_expected.to match /Does the repository contain a plain-text LICENSE file/ }
      it { is_expected.to match /Does installation proceed as outlined/ }
      it { is_expected.to match /Are there automated tests/ }
      it { is_expected.to match /Does the `paper.md` file include a list of authors/ }
    end
  end

  describe "#review_body with multiple reviewers" do
    let(:author) { create(:user) }
    let(:paper) do
      instance = build(:paper, user_id: author.id, kind: kind)
      instance.save(validate: false)
      instance
    end
    subject { paper.review_body("editor_name", "mickey,mouse") }

    context "with no paper type" do
      let(:kind) { nil }
      it { is_expected.to match /Reviewers:/ }
      it { is_expected.to match /Review checklist for @mickey/ }
      it { is_expected.to match /Review checklist for @mouse/ }
    end
  end
end

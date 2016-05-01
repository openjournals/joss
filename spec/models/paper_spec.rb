require 'rails_helper'

describe Paper do
  before(:each) do
    Paper.destroy_all
  end

  it { should belong_to(:submitting_author) }

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

  # GitHub stuff
  it "should know how to return a pretty repo name with owner" do
    paper = create(:paper, :repository_url => "https://github.com/arfon/joss-reviews")

    expect(paper.pretty_repository_name).to eq("arfon / joss-reviews")
  end

  it "should know how to return a pretty DOI" do
    paper = create(:paper, :archive_doi => "http://dx.doi.org/10.6084/m9.figshare.828487")

    expect(paper.pretty_doi).to eq("10.6084/m9.figshare.828487")
  end


  it "should know how to return a DOI with a full URL" do
    paper = create(:paper, :archive_doi => "10.6084/m9.figshare.828487")

    expect(paper.doi_with_url).to eq("http://dx.doi.org/10.6084/m9.figshare.828487")
  end

  it "should bail creating a full DOI URL if if can't figure out what to do" do
    paper = create(:paper, :archive_doi => "http://foobar.com")

    expect(paper.doi_with_url).to eq("http://foobar.com")
  end

  it "should know how to generate its review url" do
    paper = create(:paper, :review_issue_id => 999)

    expect(paper.review_url).to eq("https://github.com/openjournals/joss-reviews/issues/999")
  end

  context "when rejected" do
    it "should change the paper state" do
      paper = create(:paper, :state => "submitted")
      paper.reject!

      expect(paper.state).to eq('rejected')
    end
  end

  context "when starting review" do
    it "should change the paper state" do
      user = create(:user)
      paper = create(:paper, :sha => "48d24b0158528e85ac7706aecd8cddc4", :state => "submitted", :submitting_author => user)
      # TODO work out why this needs to be done.
      paper.sha = "48d24b0158528e85ac7706aecd8cddc4"
      paper.save
      paper.stub(:set_review_issue) { true }

      paper.start_review!
      expect(paper.state).to eq('under_review')
    end
  end
end

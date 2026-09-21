require 'rails_helper'

describe Paper, "#sync_reviewers_from_issue_body" do
  before { skip_paper_repo_url_check }

  let(:paper) { create(:under_review_paper, reviewers: ["@alice"]) }

  it "updates the reviewers column from the header" do
    body = "<!--reviewers-list-->@alice, @bob<!--end-reviewers-list-->"

    expect(paper.sync_reviewers_from_issue_body(body)).to be true
    expect(paper.reload.reviewers).to eq(["@alice", "@bob"])
  end

  it "removes reviewers no longer in the header" do
    body = "<!--reviewers-list-->@bob<!--end-reviewers-list-->"

    paper.sync_reviewers_from_issue_body(body)
    expect(paper.reload.reviewers).to eq(["@bob"])
  end

  it "clears reviewers when the header says Pending" do
    body = "<!--reviewers-list-->Pending<!--end-reviewers-list-->"

    paper.sync_reviewers_from_issue_body(body)
    expect(paper.reload.reviewers).to eq([])
  end

  it "does nothing when the list is unchanged, ignoring case" do
    body = "<!--reviewers-list-->@Alice<!--end-reviewers-list-->"

    expect(paper.sync_reviewers_from_issue_body(body)).to be false
    expect(paper.reload.reviewers).to eq(["@alice"])
  end

  it "does nothing for legacy bodies without markers" do
    expect(paper.sync_reviewers_from_issue_body("**Reviewer:** @bob")).to be false
    expect(paper.reload.reviewers).to eq(["@alice"])
  end

  describe "#reviewers_source_issue_id" do
    it "prefers the review issue and falls back to the pre-review issue" do
      expect(create(:under_review_paper).reviewers_source_issue_id).to eq(101)
      expect(create(:review_pending_paper).reviewers_source_issue_id).to eq(100)
    end
  end
end

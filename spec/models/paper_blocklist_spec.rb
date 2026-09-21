require 'rails_helper'

describe Paper, "block list check" do
  before { skip_paper_repo_url_check }

  it "refuses a submission from a blocked ORCID" do
    create(:blocked_orcid, value: "0000-0000-0000-1234")
    paper = build(:paper, submitting_author: create(:user, uid: "0000-0000-0000-1234"))

    expect(paper.save).to be false
    expect(paper.errors[:base]).to eq([Paper::BLOCKED_SUBMISSION_MESSAGE])
  end

  it "refuses a submission from a blocked repository" do
    create(:blocklist_entry, value: "github.com/arfon/fidgit")
    paper = build(:paper, repository_url: "https://github.com/arfon/fidgit")

    expect(paper.save).to be false
    expect(paper.errors[:base]).to eq([Paper::BLOCKED_SUBMISSION_MESSAGE])
  end

  it "refuses a submission from a repository under a blocked owner" do
    create(:blocklist_entry, value: "github.com/arfon")
    paper = build(:paper, repository_url: "https://github.com/arfon/anything-at-all")

    expect(paper.save).to be false
  end

  it "does not run the git repository check for blocked submissions" do
    create(:blocklist_entry, value: "github.com/arfon")
    expect(Open3).to_not receive(:capture3)

    build(:paper, repository_url: "https://github.com/arfon/anything").save
  end

  it "allows unrelated submissions" do
    create(:blocked_orcid, value: "0000-0000-0000-9999")
    create(:blocklist_entry, value: "github.com/spammer")
    paper = build(:paper, submitting_author: create(:user, uid: "0000-0000-0000-1234"), repository_url: "https://github.com/openjournals/joss")

    expect(paper.save).to be true
  end

  it "only applies on create" do
    paper = create(:paper, repository_url: "https://github.com/openjournals/joss")
    create(:blocklist_entry, value: "github.com/openjournals/joss")

    paper.title = "Renamed"
    expect(paper.save).to be true
  end
end

describe Paper, "block list check by email" do
  before { skip_paper_repo_url_check }

  it "refuses a submission from a blocked email address" do
    create(:blocklist_entry, kind: "email", value: "spammer@example.com")
    paper = build(:paper, submitting_author: create(:user, email: "Spammer@Example.com"))

    expect(paper.save).to be false
    expect(paper.errors[:base]).to eq([Paper::BLOCKED_SUBMISSION_MESSAGE])
  end

  it "refuses a submission from a blocked email domain" do
    create(:blocklist_entry, kind: "email", value: "@mailinator.com")
    paper = build(:paper, submitting_author: create(:user, email: "fresh@mailinator.com"))

    expect(paper.save).to be false
  end

  it "allows other domains" do
    create(:blocklist_entry, kind: "email", value: "@mailinator.com")
    paper = build(:paper, submitting_author: create(:user, email: "someone@university.edu"))

    expect(paper.save).to be true
  end
end

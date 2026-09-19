require 'rails_helper'

describe IssueComment do
  before { skip_paper_repo_url_check }

  describe ".role_for" do
    let(:author) { create(:user, github_username: "@Author") }
    let(:paper) { create(:review_pending_paper, submitting_author: author, reviewers: ["@rev1", "rev2"]) }

    it "identifies the bot" do
      expect(IssueComment.role_for("editorialbot", paper)).to eq("bot")
    end

    it "identifies editors regardless of case" do
      create(:editor, login: "mceditor")
      expect(IssueComment.role_for("McEditor", paper)).to eq("editor")
    end

    it "identifies the submitting author, ignoring the leading @ and case" do
      expect(IssueComment.role_for("author", paper)).to eq("author")
    end

    it "identifies assigned reviewers with or without a leading @" do
      expect(IssueComment.role_for("rev1", paper)).to eq("reviewer")
      expect(IssueComment.role_for("REV2", paper)).to eq("reviewer")
    end

    it "returns none for everybody else" do
      expect(IssueComment.role_for("random", paper)).to eq("none")
    end

    it "prefers editor over author or reviewer" do
      create(:editor, login: "rev1")
      expect(IssueComment.role_for("rev1", paper)).to eq("editor")
    end
  end

  describe ".leaderboard" do
    let(:track_a) { create(:track) }
    let(:track_b) { create(:track) }
    let(:paper_a1) { create(:review_pending_paper, track: track_a, meta_review_issue_id: 101) }
    let(:paper_a2) { create(:review_pending_paper, track: track_a, meta_review_issue_id: 102) }
    let(:paper_b1) { create(:review_pending_paper, track: track_b, meta_review_issue_id: 201) }

    before do
      # spammer: 3 distinct issues, none with a role, 4 comments
      create(:issue_comment, login: "spammer", paper: paper_a1, issue_id: 101, commented_at: 1.hour.ago)
      create(:issue_comment, login: "spammer", paper: paper_a1, issue_id: 101, commented_at: 2.hours.ago)
      create(:issue_comment, login: "spammer", paper: paper_a2, issue_id: 102, commented_at: 3.hours.ago)
      create(:issue_comment, login: "spammer", paper: paper_b1, issue_id: 201, commented_at: 4.hours.ago)

      # legit reviewer: 2 issues, both with a role
      create(:issue_comment, login: "reviewer", paper: paper_a1, issue_id: 101, role: "reviewer", commented_at: 1.day.ago)
      create(:issue_comment, login: "reviewer", paper: paper_a2, issue_id: 102, role: "reviewer", commented_at: 1.day.ago)

      # staff, excluded
      create(:issue_comment, login: "editorialbot", paper: paper_a1, issue_id: 101, role: "bot")
      create(:issue_comment, login: "an_editor", paper: paper_a1, issue_id: 101, role: "editor")

      # old comment, outside window
      create(:issue_comment, login: "old_timer", paper: paper_a1, issue_id: 101, commented_at: 40.days.ago)
    end

    it "ranks non-staff logins by distinct issues within the window" do
      rows = IssueComment.leaderboard(since: 7.days.ago)

      expect(rows.map(&:login)).to eq(["spammer", "reviewer"])

      spammer = rows.first
      expect(spammer.issues_count).to eq(3)
      expect(spammer.comments_count).to eq(4)
      expect(spammer.no_role_issues_count).to eq(3)

      reviewer = rows.last
      expect(reviewer.issues_count).to eq(2)
      expect(reviewer.no_role_issues_count).to eq(0)
    end

    it "excludes logins that are current editors even if the recorded role was none" do
      create(:editor, login: "reviewer")
      expect(IssueComment.leaderboard(since: 7.days.ago).map(&:login)).to eq(["spammer"])
    end

    it "includes old comments when the window is wide enough" do
      expect(IssueComment.leaderboard(since: 60.days.ago).map(&:login)).to include("old_timer")
    end

    it "can be filtered by track" do
      rows = IssueComment.leaderboard(since: 7.days.ago, track_id: track_b.id)

      expect(rows.map(&:login)).to eq(["spammer"])
      expect(rows.first.issues_count).to eq(1)
    end
  end
end

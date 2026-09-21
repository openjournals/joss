require 'rails_helper'

describe IssueHeader do
  describe ".reviewers" do
    it "returns nil when the body has no reviewers-list markers" do
      expect(IssueHeader.reviewers("**Reviewer:** @mschubert , @JohnCoene")).to be_nil
      expect(IssueHeader.reviewers(nil)).to be_nil
    end

    it "parses handles, normalizing the leading @ and dropping duplicates regardless of case" do
      body = "**Reviewers:** <!--reviewers-list-->@alice, bob ,@Alice, @carol-1, @BOB<!--end-reviewers-list-->"
      expect(IssueHeader.reviewers(body)).to eq(["@alice", "@bob", "@carol-1"])
    end

    it "returns an empty list for the Pending placeholder" do
      body = "**Reviewers:** <!--reviewers-list-->Pending<!--end-reviewers-list-->"
      expect(IssueHeader.reviewers(body)).to eq([])
    end

    it "ignores things that are not GitHub handles" do
      body = "<!--reviewers-list-->@alice, not a handle!, <b>x</b><!--end-reviewers-list-->"
      expect(IssueHeader.reviewers(body)).to eq(["@alice"])
    end
  end

  describe ".editor" do
    it "returns the editor handle" do
      expect(IssueHeader.editor("**Editor:** <!--editor-->@yochannah<!--end-editor-->")).to eq("@yochannah")
    end

    it "returns nil when pending or absent" do
      expect(IssueHeader.editor("**Editor:** <!--editor-->Pending<!--end-editor-->")).to be_nil
      expect(IssueHeader.editor("no markers")).to be_nil
    end
  end
end

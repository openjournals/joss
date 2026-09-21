require 'rails_helper'

describe BlocklistEntry do
  describe "normalization" do
    it "strips the orcid.org URL and upcases the checksum" do
      entry = BlocklistEntry.create!(kind: "orcid", value: " https://orcid.org/0000-0002-1825-009x/ ", reason: "Spam")
      expect(entry.value).to eq("0000-0002-1825-009X")
    end

    it "strips scheme, www, trailing slash and .git from repositories" do
      entry = BlocklistEntry.create!(kind: "repository", value: "HTTPS://www.GitHub.com/Spammer/Repo.git/", reason: "Spam")
      expect(entry.value).to eq("github.com/spammer/repo")
      expect(entry.display_value).to eq("https://github.com/spammer/repo")
    end
  end

  describe "validation" do
    it "rejects malformed ORCIDs" do
      entry = BlocklistEntry.new(kind: "orcid", value: "not-an-orcid")
      expect(entry).to_not be_valid
      expect(entry.errors[:value].first).to match(/valid ORCID/)
    end

    it "rejects a repository value with no owner" do
      entry = BlocklistEntry.new(kind: "repository", value: "https://github.com", reason: "Spam")
      expect(entry).to_not be_valid
    end

    it "requires a reason" do
      entry = BlocklistEntry.new(kind: "repository", value: "https://github.com/spammer")
      expect(entry).to_not be_valid
      expect(entry.errors[:reason]).to include("can't be blank")
    end

    it "rejects unknown kinds and duplicates" do
      expect(BlocklistEntry.new(kind: "email", value: "x@y.z")).to_not be_valid

      create(:blocklist_entry, value: "github.com/spammer/repo")
      expect(BlocklistEntry.new(kind: "repository", value: "https://GitHub.com/Spammer/Repo", reason: "Spam")).to_not be_valid
    end
  end

  describe ".repository_owner" do
    it "returns host and owner" do
      expect(BlocklistEntry.repository_owner("https://github.com/spammer/repo")).to eq("github.com/spammer")
      expect(BlocklistEntry.repository_owner("https://gitlab.com/group/sub/repo")).to eq("gitlab.com/group")
      expect(BlocklistEntry.repository_owner("https://github.com")).to be_nil
    end
  end

  describe ".blocked_orcid?" do
    it "matches regardless of URL form or case" do
      create(:blocked_orcid, value: "0000-0002-1825-009X")
      expect(BlocklistEntry.blocked_orcid?("0000-0002-1825-009x")).to be true
      expect(BlocklistEntry.blocked_orcid?("https://orcid.org/0000-0002-1825-009X")).to be true
      expect(BlocklistEntry.blocked_orcid?("0000-0002-1825-0090")).to be false
      expect(BlocklistEntry.blocked_orcid?(nil)).to be false
    end
  end

  describe ".blocked_repository?" do
    it "matches an exact repository entry in any URL form" do
      create(:blocklist_entry, value: "github.com/spammer/repo")
      expect(BlocklistEntry.blocked_repository?("https://github.com/Spammer/Repo.git")).to be true
      expect(BlocklistEntry.blocked_repository?("http://www.github.com/spammer/repo/")).to be true
      expect(BlocklistEntry.blocked_repository?("https://github.com/spammer/other")).to be false
    end

    it "matches every repository under an owner-level entry" do
      create(:blocklist_entry, value: "github.com/spammer")
      expect(BlocklistEntry.blocked_repository?("https://github.com/spammer/anything")).to be true
      expect(BlocklistEntry.blocked_repository?("https://github.com/spammer/deep/path")).to be true
      expect(BlocklistEntry.blocked_repository?("https://github.com/spammer-2/repo")).to be false
      expect(BlocklistEntry.blocked_repository?("https://gitlab.com/spammer/repo")).to be false
    end

    it "is false for blank or ownerless URLs" do
      expect(BlocklistEntry.blocked_repository?(nil)).to be false
      expect(BlocklistEntry.blocked_repository?("https://github.com")).to be false
    end
  end
end

describe BlocklistEntry, "email entries" do
  it "normalizes addresses to lowercase" do
    expect(BlocklistEntry.create!(kind: "email", value: " Spammer@Example.COM ", reason: "Spam").value).to eq("spammer@example.com")
    expect(build(:blocklist_entry, kind: "email", value: "a@example.com").kind_label).to eq("Email")
  end

  it "only accepts full addresses, never bare domains" do
    expect(BlocklistEntry.new(kind: "email", value: "not-an-email", reason: "Spam")).to_not be_valid
    expect(BlocklistEntry.new(kind: "email", value: "example.com", reason: "Spam")).to_not be_valid
    expect(BlocklistEntry.new(kind: "email", value: "@gmail.com", reason: "Spam")).to_not be_valid
    expect(BlocklistEntry.new(kind: "email", value: "spammer@gmail.com", reason: "Spam")).to be_valid
  end

  describe ".blocked_email?" do
    it "matches exact addresses regardless of case" do
      create(:blocklist_entry, kind: "email", value: "spammer@example.com")
      expect(BlocklistEntry.blocked_email?("Spammer@Example.com")).to be true
      expect(BlocklistEntry.blocked_email?("other@example.com")).to be false
    end

    it "never blocks other users at the same domain" do
      create(:blocklist_entry, kind: "email", value: "spammer@gmail.com")
      expect(BlocklistEntry.blocked_email?("innocent@gmail.com")).to be false
    end

    it "is false for blank or malformed emails" do
      create(:blocklist_entry, kind: "email", value: "spammer@example.com")
      expect(BlocklistEntry.blocked_email?(nil)).to be false
      expect(BlocklistEntry.blocked_email?("")).to be false
      expect(BlocklistEntry.blocked_email?("@example.com")).to be false
    end
  end
end

describe BlocklistEntry, ".block_all_for" do
  before { skip_paper_repo_url_check }

  let(:aeic) { create(:board_editor) }
  let(:author) { create(:user, uid: "0000-0000-0000-1234", email: "Spammer@Example.com") }
  let(:paper) { create(:paper, submitting_author: author, repository_url: "http://github.com/arfon/fidgit") }

  it "lists the ORCID, email and repository owner as candidates" do
    expect(BlocklistEntry.candidates_for(paper)).to eq([
      ["orcid", "0000-0000-0000-1234"],
      ["email", "Spammer@Example.com"],
      ["repository", "github.com/arfon"]
    ])
  end

  it "creates one entry per candidate with the editor and reason" do
    created, failed = BlocklistEntry.block_all_for(paper, editor: aeic, reason: "Spam")

    expect(failed).to be_empty
    expect(created.map(&:kind)).to eq(%w[orcid email repository])
    expect(created.map(&:value)).to eq(["0000-0000-0000-1234", "spammer@example.com", "github.com/arfon"])
    expect(created.map(&:editor).uniq).to eq([aeic])
    expect(created.map(&:reason).uniq).to eq(["Spam"])
  end

  it "skips candidates that are already blocked" do
    paper # create the paper before blocking its author
    create(:blocked_orcid, value: "0000-0000-0000-1234")
    create(:blocklist_entry, value: "github.com/arfon")

    created, failed = BlocklistEntry.block_all_for(paper, editor: aeic, reason: "Spam")

    expect(failed).to be_empty
    expect(created.map(&:kind)).to eq(["email"])
    expect(BlocklistEntry.count).to eq(3)
  end

  it "omits blank values" do
    paper # create the paper while the author still has an email
    author.update_column(:email, nil)
    expect(BlocklistEntry.candidates_for(paper).map(&:first)).to eq(%w[orcid repository])
  end
end

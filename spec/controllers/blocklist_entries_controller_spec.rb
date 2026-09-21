require 'rails_helper'

RSpec.describe BlocklistEntriesController, type: :controller do
  render_views
  let(:current_user) { create(:user, editor: create(:board_editor)) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when not logged in" do
    let(:current_user) { nil }
    it "redirects to root" do
      get :index
      expect(response).to redirect_to root_path
      expect(flash[:error]).to eql "Please login first"
    end
  end

  context "when logged in as a non-AEiC editor" do
    let(:current_user) { create(:user, editor: create(:editor)) }
    it "redirects to root" do
      get :index
      expect(response).to redirect_to root_path
      expect(flash[:error]).to eql "You are not permitted to view that page"
    end

    it "cannot add entries" do
      post :create, params: { blocklist_entry: { kind: "repository", value: "https://github.com/x/y", reason: "Spam" } }
      expect(response).to redirect_to root_path
      expect(BlocklistEntry.count).to eq(0)
    end
  end

  describe "#index" do
    it "lists entries with who added them" do
      editor = create(:board_editor, first_name: "Ada", last_name: "Lovelace")
      create(:blocklist_entry, value: "github.com/spammer", reason: "Repeated spam", editor: editor)
      create(:blocked_orcid, value: "0000-0000-0000-9999", editor: editor)

      get :index

      expect(response).to be_successful
      expect(response.body).to have_link("https://github.com/spammer")
      expect(response.body).to have_link("0000-0000-0000-9999", href: "https://orcid.org/0000-0000-0000-9999")
      expect(response.body).to have_content("Repeated spam")
      expect(response.body).to have_content("Ada Lovelace")
    end

    it "shows an empty message" do
      get :index
      expect(response.body).to have_content("The block list is empty")
    end
  end

  describe "#create" do
    it "adds a normalized repository entry attributed to the current editor" do
      request.env["HTTP_REFERER"] = blocklist_entries_path
      post :create, params: { blocklist_entry: { kind: "repository", value: "https://GitHub.com/Spammer/", reason: "Spam" } }

      expect(response).to redirect_to blocklist_entries_path
      entry = BlocklistEntry.last
      expect(entry.value).to eq("github.com/spammer")
      expect(entry.editor).to eq(current_user.editor)
      expect(flash[:notice]).to match(/Added https:\/\/github.com\/spammer/)
    end

    it "adds an ORCID entry from a URL" do
      post :create, params: { blocklist_entry: { kind: "orcid", value: "https://orcid.org/0000-0002-1825-009x", reason: "Spam" } }

      expect(BlocklistEntry.last.value).to eq("0000-0002-1825-009X")
    end

    it "adds an email entry but refuses a bare domain" do
      post :create, params: { blocklist_entry: { kind: "email", value: "Spammer@Example.com", reason: "Spam" } }
      expect(BlocklistEntry.last.value).to eq("spammer@example.com")

      post :create, params: { blocklist_entry: { kind: "email", value: "@gmail.com", reason: "Spam" } }
      expect(flash[:error]).to match(/full email address/)
      expect(BlocklistEntry.count).to eq(1)
    end

    it "requires a reason" do
      post :create, params: { blocklist_entry: { kind: "repository", value: "https://github.com/spammer" } }

      expect(flash[:error]).to match(/Reason can't be blank/)
      expect(BlocklistEntry.count).to eq(0)
    end

    it "reports validation errors" do
      post :create, params: { blocklist_entry: { kind: "orcid", value: "nope", reason: "Spam" } }

      expect(response).to redirect_to blocklist_entries_path
      expect(flash[:error]).to match(/valid ORCID/)
      expect(BlocklistEntry.count).to eq(0)
    end

    it "redirects back to the referring page, e.g. a paper's admin page" do
      request.env["HTTP_REFERER"] = "/papers/abc/admin"
      post :create, params: { blocklist_entry: { kind: "repository", value: "https://github.com/spammer/repo", reason: "Spam" } }

      expect(response).to redirect_to "/papers/abc/admin"
    end
  end

  describe "#block_paper" do
    before { skip_paper_repo_url_check }

    let(:author) { create(:user, uid: "0000-0000-0000-1234", email: "spammer@example.com") }
    let(:paper) { create(:paper, submitting_author: author, repository_url: "http://github.com/arfon/fidgit") }

    it "blocks the ORCID, email and repository owner and returns to the admin page" do
      post :block_paper, params: { paper_sha: paper.sha, reason: "Spam submission" }

      expect(response).to redirect_to "/papers/#{paper.sha}/admin"
      expect(BlocklistEntry.pluck(:kind, :value)).to contain_exactly(
        ["orcid", "0000-0000-0000-1234"],
        ["email", "spammer@example.com"],
        ["repository", "github.com/arfon"]
      )
      expect(BlocklistEntry.pluck(:reason).uniq).to eq(["Spam submission"])
      expect(BlocklistEntry.pluck(:editor_id).uniq).to eq([current_user.editor.id])
      expect(flash[:notice]).to match(/Blocked 0000-0000-0000-1234, spammer@example.com, and https:\/\/github.com\/arfon/)
    end

    it "requires a reason" do
      post :block_paper, params: { paper_sha: paper.sha, reason: " " }

      expect(flash[:error]).to match(/give a reason/)
      expect(BlocklistEntry.count).to eq(0)
    end

    it "is idempotent" do
      post :block_paper, params: { paper_sha: paper.sha, reason: "Spam" }
      post :block_paper, params: { paper_sha: paper.sha, reason: "Spam" }

      expect(BlocklistEntry.count).to eq(3)
      expect(flash[:notice]).to match(/already blocked/)
    end

    it "is not available to non-AEiCs" do
      allow(controller).to receive(:current_user).and_return(create(:user, editor: create(:editor)))
      post :block_paper, params: { paper_sha: paper.sha, reason: "Spam" }

      expect(response).to redirect_to root_path
      expect(BlocklistEntry.count).to eq(0)
    end
  end

  describe "#destroy" do
    it "removes an entry" do
      entry = create(:blocklist_entry)
      delete :destroy, params: { id: entry.id }

      expect(response).to redirect_to blocklist_entries_path
      expect(BlocklistEntry.exists?(entry.id)).to be false
    end
  end
end

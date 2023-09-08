RSpec.describe Repository do
  let(:config) do
    YAML.load <<-YAML.strip_heredoc
      a_user/a_repository:
        editor_team_id: 1234
        papers: a_user/another_repository
    YAML
  end

  before(:each) do
    allow(Repository).to receive(:config).and_return(config)
  end

  describe ".nwo" do
    it "returns the configured repository nwo" do
      expect(Repository.nwo).to eq("a_user/a_repository")
    end
  end

  describe ".papers" do
    it "returns the configured papers repository" do
      expect(Repository.papers).to eq("a_user/another_repository")
    end
  end

  describe ".editors" do
    before(:each) { Rails.cache.clear }
    let(:response_users) do
      %w(two one three).map{ |u| double(login: u) }
    end

    it "loads the correct team id" do
      expect(GITHUB).to receive(:team_members).with(1234).and_return([])
      Repository.editors
    end

    it "sorts the user logins" do
      allow(GITHUB).to receive(:team_members).with(1234).and_return(response_users)
      expect(Repository.editors).to eq(%w(@one @three @two))
    end

    it "uses the cached results" do
      Rails.cache.write("repository.editors", %w(@one @three @two))
      expect(GITHUB).to_not receive(:team_members)
      Repository.editors
    end
  end

  describe ".invite_to_editors_team" do
    it "returns false if GitHub user does not exist" do
      expect(Octokit).to receive(:user).and_raise(Octokit::NotFound)
      expect(Repository.invite_to_editors_team("unexistent_user")).to be false
    end

    it "returns false invitation is not created" do
      expect(Octokit).to receive(:user).and_return(OpenStruct.new(id: 33))
      expected_url = "https://api.github.com/orgs/openjournals/invitations"
      expected_params = {invitee_id: 33, team_ids: [1234]}
      exheaders = {"Authorization" => "token testGHtoken", "Content-Type" => "application/json", "Accept" => "application/vnd.github.v3+json"}
      expect(Faraday).to receive(:post).with(expected_url, expected_params.to_json, exheaders).and_return(OpenStruct.new(status: 404))

      expect(Repository.invite_to_editors_team("unexistent_user")).to be false
    end

    it "returns true if invitation is created" do
      expect(Octokit).to receive(:user).and_return(OpenStruct.new(id: 42))
      expected_url = "https://api.github.com/orgs/openjournals/invitations"
      expected_params = {invitee_id: 42, team_ids: [1234]}
      exheaders = {"Authorization" => "token testGHtoken", "Content-Type" => "application/json", "Accept" => "application/vnd.github.v3+json"}
      expect(Faraday).to receive(:post).with(expected_url, expected_params.to_json, exheaders).and_return(OpenStruct.new(status: 200))

      expect(Repository.invite_to_editors_team("unexistent_user")).to be true
    end
  end
end

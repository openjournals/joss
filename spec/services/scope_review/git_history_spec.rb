require "rails_helper"
require "tmpdir"

RSpec.describe ScopeReview::GitHistory do
  # Builds a real git repository with back-dated commits so history signals
  # are computed exactly as they will be in production.
  def build_repo(dir)
    run(dir, "git init -q -b main")
    run(dir, "git config user.name 'Ada Lovelace'")
    run(dir, "git config user.email 'ada@example.org'")

    commit(dir, "2022-01-10T12:00:00Z", "initial code") do
      write(dir, "src/core.py", "print('hello')\n" * 50)
    end
    commit(dir, "2022-08-15T12:00:00Z", "more code") do
      write(dir, "src/extra.py", "x = 1\n" * 80)
    end
    commit(dir, "2024-03-01T12:00:00Z", "big data drop",
           name: "alovelace", email: "ada@example.org") do
      write(dir, "data/big.csv", "1,2,3\n" * 3000)
    end
    commit(dir, "2024-06-01T12:00:00Z", "paper") do
      write(dir, "paper/paper.md", "---\ntitle: x\n---\n# Statement of need\n")
    end
    commit(dir, "2024-07-01T12:00:00Z", "bump deps",
           name: "dependabot[bot]", email: "49699333+dependabot[bot]@users.noreply.github.com") do
      write(dir, "requirements.txt", "numpy==2.0\n")
    end
    commit(dir, "2024-07-02T12:00:00Z", "auto-format",
           name: "GitHub Actions", email: "actions@github.com") do
      write(dir, "src/core.py", "print('hello')\n" * 51)
    end
    run(dir, "git tag v1.0.0")
  end

  def write(dir, rel, content)
    path = File.join(dir, rel)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def commit(dir, date, message, name: nil, email: nil)
    yield
    run(dir, "git add -A")
    env = { "GIT_AUTHOR_DATE" => date, "GIT_COMMITTER_DATE" => date }
    env["GIT_AUTHOR_NAME"] = name if name
    env["GIT_AUTHOR_EMAIL"] = email if email
    _, stderr, status = Open3.capture3(env, "git", "-C", dir, "commit", "-q", "-m", message)
    raise "commit failed: #{stderr}" unless status.success?
  end

  def run(dir, cmd)
    _, stderr, status = Open3.capture3("git -C #{dir} #{cmd.delete_prefix('git ')}")
    raise "#{cmd} failed: #{stderr}" unless status.success?
  end

  around do |example|
    Dir.mktmpdir("gh-spec-") do |dir|
      @dir = dir
      build_repo(dir)
      example.run
    end
  end

  subject(:history) { described_class.new(@dir) }

  it "finds the first commit date" do
    expect(history.first_commit[:timestamp]).to eq(Time.utc(2022, 1, 10, 12).to_i)
    expect(history.first_commit[:date]).to eq("January 10, 2022")
  end

  it "counts commits" do
    expect(history.commit_count).to eq(6)
  end

  it "detects the dominant insertion window and classifies it as data" do
    top = history.code_windows.first
    expect(top[:percentage]).to be > 75
    expect(top[:signal]).to eq("critical")
    expect(top[:is_data]).to be(true)
    expect(top[:data_fraction]).to be > 0.9
  end

  it "keeps windows non-overlapping and sorted by share" do
    windows = history.code_windows
    expect(windows.length).to be_between(1, 3)
    expect(windows.map { |w| w[:percentage] }).to eq(windows.map { |w| w[:percentage] }.sort.reverse)
    windows.combination(2).each do |a, b|
      overlap = !(a[:window_end] < b[:window_start] || a[:window_start] > b[:window_end])
      expect(overlap).to be(false)
    end
  end

  it "scopes first-commit dates to a path" do
    expect(history.first_commit_for_path("paper")[:timestamp]).to eq(Time.utc(2024, 6, 1, 12).to_i)
    expect(history.first_commit_for_path("src")[:timestamp]).to eq(Time.utc(2022, 1, 10, 12).to_i)
    expect(history.first_commit_for_path("nonexistent")).to be_nil
  end

  it "merges split author identities by email and excludes bots" do
    expect(history.authors.length).to eq(4) # 'Ada Lovelace' + 'alovelace' + two bots
    expect(history.merged_authors.length).to eq(1) # one human; dependabot is not a collaborator
    expect(history.merged_authors.first[:commits]).to eq(4)
  end

  it "counts tags" do
    expect(history.tags_count).to eq(1)
  end
end

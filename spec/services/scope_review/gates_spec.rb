require "rails_helper"

RSpec.describe ScopeReview::Gates do
  # Fixed "today" so age math is deterministic.
  let(:today) { Time.utc(2026, 7, 17) }

  # A healthy, unambiguous submission: 3.5 years old, multi-committer,
  # tested, MIT, distributed history. Individual examples mutate this.
  def repo_info(overrides = {})
    {
      repo_url: "https://github.com/example/tool",
      host: "github",
      first_commit: { date: "January 01, 2023", timestamp: Time.utc(2023, 1, 1).to_i },
      path_scoped_age: {
        paper_dir: { path: "paper", timestamp: Time.utc(2025, 6, 1).to_i, date: "June 01, 2025" },
        primary_src_dir: { path: "src", timestamp: Time.utc(2023, 2, 1).to_i, date: "February 01, 2023" },
      },
      code_windows: [
        { percentage: 12.0, signal: "healthy", is_data: false, data_fraction: 0.1,
          window_start: "2023-05-01T00:00:00Z", window_end: "2023-05-03T00:00:00Z", insertions: 1200 },
      ],
      languages: { top_languages: %w[Python Shell], data_fraction: 0.1 },
      authors: [
        { name: "Ada Lovelace", email: "ada@example.org", commits: 100 },
        { name: "Grace Hopper", email: "grace@example.org", commits: 40 },
      ],
      authors_merged: 2,
      tests: { has_automated: true, kind: "pytest", notebooks_only: false,
               ci_present: true, ci_runs_tests: true, test_file_count: 12 },
      license: { spdx_id: "MIT", osi_approved: true, file: "LICENSE" },
      community_files: { readme: true, contributing: true, changelog: true, docs_dir: true },
      paper: { found: true, authors: ["Ada Lovelace", "Grace Hopper"], bib_authors: ["Alan Turing"] },
      engagement: { available: true, unique_participants: 5, issue_count: 20, pr_count: 8 },
      sibling_repos: [],
    }.deep_merge(overrides)
  end

  def evaluate(info, paper_text: nil, software_version: "v1.0.0")
    described_class.evaluate(info, paper_text: paper_text, software_version: software_version, today: today)
  end

  describe "a clean submission" do
    it "passes every deterministic gate and routes to L2" do
      result = evaluate(repo_info)

      expect(result[:gates].values_at(:license, :gate1_development_history, :gate3a_open_development,
                                      :gate3b_collaborative_effort, :gate4_iterative_development))
        .to all(eq("pass"))
      expect(result[:gates][:gate2_research_impact]).to eq("unknown")
      expect(result[:triggers]).to be_empty
      expect(result[:routing]).to eq(:l2)
    end

    it "never decides Gate 2 deterministically" do
      expect(evaluate(repo_info)[:gates][:gate2_research_impact]).to eq("unknown")
    end
  end

  describe "Gate 1 — development history" do
    it "clean-fails a repository younger than 6 months" do
      info = repo_info(first_commit: { date: "May 01, 2026", timestamp: Time.utc(2026, 5, 1).to_i })
      result = evaluate(info)

      expect(result[:gates][:gate1_development_history]).to eq("fail")
      expect(result[:routing]).to eq(:clean_fail)
      expect(result[:hard_fails]).to include(:gate1_development_history)
    end

    it "is unknown (escalates) when the first commit could not be computed" do
      result = evaluate(repo_info(first_commit: nil))
      expect(result[:gates][:gate1_development_history]).to eq("unknown")
      expect(result[:routing]).to eq(:l3)
    end

    it "escalates a critical code window as a repo dump, without failing outright" do
      info = repo_info(code_windows: [
                         { percentage: 86.0, signal: "critical", is_data: false, data_fraction: 0.05,
                           window_start: "2026-01-01T00:00:00Z", window_end: "2026-01-03T00:00:00Z", insertions: 90_000 },
                       ])
      result = evaluate(info)

      expect(result[:gates][:gate1_development_history]).to eq("pass")
      expect(result[:triggers].map { |t| t[:name] }).to include("repo_dump")
      expect(result[:routing]).to eq(:l3)
    end

    it "classifies a data-dominated spike as data-masked, not a dump (metbit/dbgsom pattern)" do
      info = repo_info(code_windows: [
                         { percentage: 74.0, signal: "strong", is_data: true, data_fraction: 0.9,
                           window_start: "2025-01-01T00:00:00Z", window_end: "2025-01-03T00:00:00Z", insertions: 500_000 },
                       ])
      names = evaluate(info)[:triggers].map { |t| t[:name] }
      expect(names).to include("data_masked_spike")
      expect(names).not_to include("repo_dump")
    end

    it "escalates when the primary source directory is younger than 6 months despite an old repo (FlashSpec pattern)" do
      info = repo_info(path_scoped_age: {
                         primary_src_dir: { path: "flashspec", timestamp: Time.utc(2026, 3, 1).to_i, date: "March 01, 2026" },
                       })
      result = evaluate(info)
      expect(result[:gates][:gate1_development_history]).to eq("pass")
      expect(result[:triggers].map { |t| t[:name] }).to include("age_code_mismatch")
      expect(result[:routing]).to eq(:l3)
    end

    it "escalates a new module in an old repo (3W toolkit pattern)" do
      info = repo_info(
        first_commit: { date: "January 01, 2022", timestamp: Time.utc(2022, 1, 1).to_i },
        path_scoped_age: {
          primary_src_dir: { path: "toolkit", timestamp: Time.utc(2025, 10, 1).to_i, date: "October 01, 2025" },
        }
      )
      expect(evaluate(info)[:triggers].map { |t| t[:name] }).to include("age_code_mismatch")
    end
  end

  describe "License gate" do
    it "fails a known non-OSI license" do
      info = repo_info(license: { spdx_id: "CC-BY-4.0", osi_approved: false, file: "LICENSE" })
      result = evaluate(info)
      expect(result[:gates][:license]).to eq("fail")
      expect(result[:routing]).to eq(:clean_fail)
    end

    it "treats an unidentifiable license as unknown, not a failure" do
      info = repo_info(license: { spdx_id: nil, osi_approved: nil, file: "LICENSE" })
      result = evaluate(info)
      expect(result[:gates][:license]).to eq("unknown")
      expect(result[:routing]).to eq(:l3)
    end
  end

  describe "Gate 3a — automated tests" do
    it "clean-fails when there is no automated test suite" do
      info = repo_info(tests: { has_automated: false, kind: "none", notebooks_only: false,
                                ci_present: true, ci_runs_tests: false, test_file_count: 0 })
      result = evaluate(info)
      expect(result[:gates][:gate3a_open_development]).to eq("fail")
      expect(result[:routing]).to eq(:clean_fail)
    end

    it "escalates notebooks-only test evidence instead of passing or failing (PIEC/AeroLab pattern)" do
      info = repo_info(tests: { has_automated: false, kind: "none", notebooks_only: true,
                                ci_present: false, ci_runs_tests: false, test_file_count: 3 })
      result = evaluate(info)
      expect(result[:gates][:gate3a_open_development]).to eq("unknown")
      expect(result[:triggers].map { |t| t[:name] }).to include("fake_test_signal")
      expect(result[:routing]).to eq(:l3)
    end
  end

  describe "Gate 3b — collaborative effort (tri-state, host-sensitive)" do
    let(:solo_authors) do
      {
        authors: [{ name: "Ada Lovelace", email: "ada@example.org", commits: 140 }],
        authors_merged: 1,
        paper: { found: true, authors: ["Ada Lovelace"], bib_authors: [] },
      }
    end

    it "escalates a solo project with zero engagement rather than failing (paper evidence must be checked)" do
      info = repo_info(solo_authors.deep_merge(engagement: { available: true, unique_participants: 0 }))
      result = evaluate(info)
      expect(result[:gates][:gate3b_collaborative_effort]).to eq("unknown")
      expect(result[:triggers].map { |t| t[:name] }).to include("solo_no_engagement")
      expect(result[:routing]).to eq(:l3)
    end

    it "NEVER auto-fails on a host without engagement data — missing is not zero (GitLab rule)" do
      info = repo_info(solo_authors.merge(
                         host: "gitlab",
                         engagement: { available: false }
                       ))
      result = evaluate(info)
      expect(result[:gates][:gate3b_collaborative_effort]).to eq("unknown")
      expect(result[:gates].values).not_to include("fail")
      expect(result[:triggers].map { |t| t[:name] }).to include("engagement_unknown")
      expect(result[:routing]).to eq(:l3)
    end

    it "passes a multi-committer project on any host" do
      info = repo_info(host: "gitlab", engagement: { available: false })
      expect(evaluate(info)[:gates][:gate3b_collaborative_effort]).to eq("pass")
    end

    it "passes a solo committer with a multi-author paper (advisors count as community context)" do
      info = repo_info(solo_authors.deep_merge(paper: { authors: ["Ada Lovelace", "Charles Babbage"] }))
      expect(evaluate(info)[:gates][:gate3b_collaborative_effort]).to eq("pass")
    end

    it "passes a solo committer with external issue/PR participants" do
      info = repo_info(solo_authors.deep_merge(engagement: { available: true, unique_participants: 4 }))
      expect(evaluate(info)[:gates][:gate3b_collaborative_effort]).to eq("pass")
    end

    it "flags inflated contributor counts from split identities (dbgsom pattern)" do
      info = repo_info(
        authors: [
          { name: "Ada Lovelace", email: "ada@example.org", commits: 90 },
          { name: "alovelace", email: "ada@example.org", commits: 30 },
          { name: "Ada L", email: "ada@users.noreply.github.com", commits: 20 },
        ],
        authors_merged: 1,
        paper: { found: true, authors: ["Ada Lovelace"], bib_authors: [] },
        engagement: { available: true, unique_participants: 2 }
      )
      expect(evaluate(info)[:triggers].map { |t| t[:name] }).to include("split_identity")
    end
  end

  describe "Gate 4 — iterative development" do
    it "escalates a single-burst history (lean fail, confirmed at L3)" do
      info = repo_info(code_windows: [
                         { percentage: 97.0, signal: "critical", is_data: false, data_fraction: 0.1,
                           window_start: "2025-01-01T00:00:00Z", window_end: "2025-01-03T00:00:00Z", insertions: 50_000 },
                         { percentage: 2.0, signal: "healthy", is_data: false, data_fraction: 0.0,
                           window_start: "2025-02-01T00:00:00Z", window_end: "2025-02-03T00:00:00Z", insertions: 900 },
                       ])
      result = evaluate(info)
      expect(result[:gates][:gate4_iterative_development]).to eq("unknown")
      expect(result[:triggers].map { |t| t[:name] }).to include("single_burst")
    end

    it "passes distributed histories" do
      expect(evaluate(repo_info)[:gates][:gate4_iterative_development]).to eq("pass")
    end
  end

  describe "cross-cutting anomaly triggers" do
    it "flags self-citation overlap between paper authors and bibliography (citrees pattern)" do
      info = repo_info(paper: { found: true, authors: ["Ada Lovelace"],
                                bib_authors: ["A. Lovelace", "Alan Turing"] })
      expect(evaluate(info)[:triggers].map { |t| t[:name] }).to include("self_citation_overlap")
    end

    it "flags web tools by dominant language (FlexibleGLMM/FAIVOR pattern)" do
      info = repo_info(languages: { top_languages: %w[JavaScript HTML], data_fraction: 0.1 })
      result = evaluate(info)
      expect(result[:triggers].map { |t| t[:name] }).to include("web_tool")
      expect(result[:routing]).to eq(:l3)
    end

    it "flags web tools by paper text" do
      result = evaluate(repo_info, paper_text: "We present a Shiny app for exploring GLMM fits.")
      expect(result[:triggers].map { |t| t[:name] }).to include("web_tool")
    end

    it "flags possibly inherited impact for v2+ submissions (3W/DESDEO2 pattern)" do
      result = evaluate(repo_info, software_version: "v3.0.0")
      expect(result[:triggers].map { |t| t[:name] }).to include("inherited_impact")
    end

    it "flags inherited impact when the paper mentions a predecessor" do
      result = evaluate(repo_info, paper_text: "This package is a fork of Auspice, extended for clonal families.")
      expect(result[:triggers].map { |t| t[:name] }).to include("inherited_impact")
    end
  end

  describe "soft triggers" do
    it "split identity alone does not force L3 — it rides along to L2 as context" do
      info = repo_info(
        authors: [
          { name: "Ada Lovelace", email: "ada@example.org", commits: 90 },
          { name: "alovelace", email: "ada@example.org", commits: 30 },
          { name: "Grace Hopper", email: "grace@example.org", commits: 40 },
        ],
        authors_merged: 2
      )
      result = evaluate(info)
      expect(result[:triggers].map { |t| t[:name] }).to contain_exactly("split_identity")
      expect(result[:routing]).to eq(:l2)
    end

    it "self-citation overlap is a hard trigger — the cheap model is unstable on it" do
      info = repo_info(paper: { found: true, authors: ["Ada Lovelace"], bib_authors: ["A. Lovelace"] })
      result = evaluate(info)
      expect(result[:triggers].map { |t| t[:name] }).to include("self_citation_overlap")
      expect(result[:routing]).to eq(:l3)
    end
  end

  describe "routing precedence" do
    it "clean_fail wins over escalation triggers" do
      info = repo_info(
        tests: { has_automated: false, kind: "none", notebooks_only: false, ci_present: false, ci_runs_tests: false, test_file_count: 0 },
        languages: { top_languages: %w[JavaScript], data_fraction: 0.1 }
      )
      expect(evaluate(info)[:routing]).to eq(:clean_fail)
    end
  end
end

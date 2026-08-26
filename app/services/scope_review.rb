# Automated / assisted scope screening for incoming submissions.
#
# Pipeline (see docs/scope_review.md):
#   L0 ScopeReview::RepoInfo      — computed signals from a clone + host APIs
#   L1 ScopeReview::Gates         — deterministic tri-state gate predicates
#   L2 ScopeReview::Triage        — single cheap-model pass on clean cases
#   L3 ScopeReview::Investigator  — bounded agentic pass on ambiguous cases
#
# ScopeReview::Runner orchestrates the ladder and records a ScopeAssessment.
# Nothing in this namespace performs an outward action (GitHub writes,
# author email) — a human actions every outcome from the dashboard.
module ScopeReview
  # Tunables live under the `scope_review` key of config/settings-<env>.yml so
  # thresholds can change without touching code.
  def self.config(key, default = nil)
    cfg = Rails.application.settings[:scope_review] || {}
    cfg.key?(key) ? cfg[key] : default
  end

  def self.enabled?
    config(:enabled, false)
  end
end

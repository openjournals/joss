# Automated / Assisted Scope Review

Automated screening of incoming submissions against the 2026 editorial scope
criteria. It drafts; humans decide. The pipeline itself never posts to GitHub
or emails an author. The one outward action lives behind an explicit human
click: **desk reject** on the paper admin page (`PapersController#desk_reject`)
rejects the paper and optionally sends the editor-reviewed note to the
submitting author via `Notifications.author_rejection_email` — for the clear
failures that never need a public `joss-reviews` issue.

## Architecture

```
Paper (submitted / review_pending, no editor)
   │  rake scope_review:sweep            ← Heroku Scheduler, every ~10 min
   ▼
ScopeReview::Runner
   ├─ pre-flight (GitHub API): repo size gate, license, default branch
   ├─ clone (full history, tmpdir, host-agnostic)
   ├─ L0  ScopeReview::RepoInfo    computed signals (no model)
   ├─ L1  ScopeReview::Gates       deterministic tri-state gates + anomaly triggers
   ├─ L2  ScopeReview::Triage      one cheap-model pass on clean cases (Haiku)
   └─ L3  ScopeReview::Investigator bounded agentic pass on ambiguous cases (Sonnet)
   ▼
ScopeAssessment row
   │
   ├─ /scope_assessments — the AEiC work queue (filterable by track)
   └─ /papers/:sha — assessment card on the paper page (AEiC-only):
        gates, triggers, evidence trail, editable draft note, and the
        decision controls (agree / override / re-run / desk-reject)
```

Assessments can also be triggered from the paper admin page ("Run scope
assessment" / "Re-run") — these enqueue `ScopeAssessmentJob`, which runs on
Rails' built-in in-process :async adapter (no queue infrastructure); a job
lost to a dyno restart is recovered by the next sweep.

Routing: any deterministic hard fail → `DESK_REJECT` recommendation with a
templated draft note (no model involved); clean pass → L2; any unknown gate or
anomaly trigger → L3. Model output can only fill gates L1 left `unknown`
(shown as `model:pass` etc.) — it never overrides a deterministic value.

Fail-safe invariants:

* **unknown ≠ fail** — missing data (e.g. no engagement API for GitLab repos)
  escalates to a human; it never desk-rejects.
* **any cap/error → needs_manual** — clone timeouts, oversized repos, L3
  budget exhaustion, and API errors all land in the manual queue, never in a
  verdict.
* **prompt injection containment** — the paper text is fenced and labelled
  untrusted; actions are gated on computed facts, not model prose; the L3
  tool is a read-only GET allowlist scoped to the submission's GitHub owner
  with hard budgets (15 tool calls, 30 s/call, 5 min wall clock).

## The rubric is the source of truth

`config/scope_review/instructions.md` is fed verbatim to L2/L3 as the system
prompt. The deterministic predicates in `app/services/scope_review/gates.rb`
encode only its mechanically-checkable parts. **If the rubric changes, review
the gates (and their specs) in lockstep** — they are two encodings of the same
policy.

## Configuration

`config/settings-<env>.yml`, under `scope_review:`

| key | default | meaning |
|---|---|---|
| `enabled` | false | master switch for the sweep |
| `max_repo_size_kb` | 1048576 (1 GB) | GitHub pre-flight threshold; larger repos go straight to `needs_manual` without cloning |
| `clone_timeout` | 600 | seconds before a clone is killed |
| `history_commit_cap` | 5000 | most-recent commits analyzed for insertion windows |
| `triage_model` | claude-haiku-4-5 | L2 model |
| `investigator_model` | claude-sonnet-5 | L3 model |
| `triage_confidence_threshold` | 0.75 | below this, L2 escalates to L3 |

Environment variables: `ANTHROPIC_API_KEY` (without it the deterministic
layers still run — clean fails are drafted, everything else lands in the
manual queue with full signals attached), `GH_TOKEN` (already required by the
app; used read-only here).

## Running

```
rake scope_review:sweep                # assess unassessed incoming papers (LIMIT=10)
rake scope_review:sweep STALE=1        # also re-assess papers whose repo HEAD moved
rake scope_review:assess PAPER_ID=123  # force one paper
```

On Heroku: add a Scheduler job running `rake scope_review:sweep` every 10
minutes. Each run is a one-off dyno; runs with no work exit in seconds.

## Rollout (shadow mode)

1. Deploy with `enabled: true` and let assessments accumulate silently.
2. AEiCs record agree/override from `/scope_assessments` as they make their
   normal decisions — this is the calibration signal.
3. Watch: recommendation distribution, tier-reached distribution (L3 rate),
   override rate, `needs_manual`/`error` rate, time per assessment.
4. Only once agreement is demonstrably high should the drafts start being
   used as the primary basis for author-facing notes.

Desk-rejects handled off-GitHub still need a logged reason, a clear
author-facing message, and a documented appeal path — the `ScopeAssessment`
row is that audit record (append-only: re-runs create new rows).

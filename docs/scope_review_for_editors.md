# Automated scope screening — a guide for editors

> **This is an experiment we are running with the editorial team.** It is new,
> switched on deliberately and gradually, and it is not a settled part of the
> workflow. Nothing it produces is binding — editors make every decision, as
> always. We are running it precisely to find out whether it is actually
> helpful and trustworthy, and your feedback (and your agree/override clicks —
> see below) is how we decide whether to keep it, change it, or drop it. Please
> tell us what's wrong with its suggestions; that's the point of the exercise.

This explains what the automated scope screening is for, what you see and do
as an editor, and — for whoever maintains JOSS — how to change how it behaves
later. It deliberately avoids the mechanical detail of each check; for that and
the system architecture see [`scope_review.md`](scope_review.md).

## What it is for

Since 2026 new submissions needs additional editorial checks before an editor
is assigned: does it show enough public development history, demonstrated
research impact, open-source practice (including automated tests), community
context, and iterative development? Doing this by hand for every submission is
slow and repetitive, even though most of the signal is mechanical.

The screening automates the **mechanical triage and the first draft of the
decision**, and stops there. It is an assistant, not an autopilot:

- It reads text and metadata — the paper, the git history, the repository tree,
  the licence, GitHub activity. It never runs the submitted code.
- It produces a **recommendation and a draft note**, never an action. No email
  is sent and no GitHub issue is touched unless *you* click to do it.
- Its goal is to save you time on the clear cases and to gather the evidence for
  the genuinely ambiguous ones — not to make the call for you.

The irreversible, outward-facing decision always stays with a human.

## What you see

Two places surface the screening, both editor-facing:

- **The incoming dashboard** ("Papers with no editor") has a **Screening**
  column showing each paper's recommendation as a small badge. This is for
  triage at a glance — spotting the clear desk-rejects in a long queue.
- **The paper page** carries an **assessment card**: the recommendation, each
  criterion with a plain-language result and a hover explanation, any anomalies
  the automation flagged, an editable draft note, and the decision buttons.
  There is also a queue of everything awaiting review at `/scope_assessments`.

### The recommendations

| Recommendation | What it means for you |
|---|---|
| **Proceed** | Looks clear on every criterion. Assign an editor as usual. |
| **Borderline proceed** | Leans proceed, with a caveat worth a glance. |
| **Requires verification** | Genuinely ambiguous — the automation gathered evidence but wants a human to make the call. Read the summary. |
| **Desk reject** | A clear failure (usually a mechanical one like too little history or no tests). Review the draft note and decide whether to send it. |
| **Needs manual** | The automation couldn't assess it at all (no paper file found, repository too large to clone, an error). Assess by hand. |

Two things to internalise, because they are easy to misread:

- A criterion marked **"?" (unknown) never counts against a submission.** It
  means "not decided automatically", not "failed". Research impact, for
  instance, is *always* left to judgment — it is never failed by the machine
  alone.
- A recommendation is **advisory**. Recording your decision is what carries
  editorial weight, and the buttons below make that explicit.

## What you do

On the assessment card:

- **Desk reject** rejects the paper and, if you tick the box, emails the
  (editable) draft note to the submitting author. This is for clear failures
  that never need a public review issue — it keeps the process quieter and
  gentler for the author. Nothing is sent until you click, and you can edit the
  note first.
- **Agree** / **Override** record whether the automation got it right, *without*
  touching the paper. Use these when you're actioning the outcome elsewhere
  (e.g. on GitHub) but still want to log whether the screening was correct.
- **Re-run** re-screens the paper — useful after an author pushes a fix (adds a
  paper file, adds tests).

**Please record a decision even when you act elsewhere.** Every agree/override
is calibration data: it is how we measure whether the automation is trustworthy
and where it needs tuning. During the initial rollout the screening runs
silently alongside your normal decisions precisely so we can compare the two
before relying on it.

## Why some assessments are instant and some take minutes

The screening works in tiers, cheapest first, and only escalates when it needs
to:

1. **The clear cases** are decided from repository facts alone — no AI model, a
   few seconds, effectively free. A repository that is three months old or has
   no tests is a desk-reject without anything further.
2. **The clean-looking cases** get a single quick AI read of the paper to judge
   research impact.
3. **The genuinely ambiguous cases** get a deeper AI investigation that can look
   things up on GitHub (past commits, whether a cited paper's authors are
   independent, whether the real software lives in another repository). These
   take a few minutes and cost more, which is why they are reserved for the
   cases that actually need them.

Roughly two-thirds of submissions are settled in the cheap tiers. If any step
hits a limit or an error, the paper goes to the manual queue — it never guesses.

## What is safe, and what its limits are

- It **cannot take an outward action on its own.** The worst a bad assessment
  can do is put a misleading draft in front of you, which you review.
- It is **resistant to manipulation.** The paper text is treated as untrusted —
  a submitter can't hide an instruction in their paper to force a decision,
  because the actual outcome is gated on computed facts, and the deeper
  investigation can only *read* a fixed set of GitHub endpoints for the
  submission's own repository.
- It is **conservative by design.** When strong software falls short only on
  demonstrated impact, the automation will not desk-reject it — it downgrades to
  "requires verification" and asks you, because "the software is excellent but
  its impact evidence is thin" is a judgment call, not a mechanical one.
- Desk-rejects handled in-app (not on GitHub) still need a logged reason, a
  clear author message, and an appeal path. The assessment record is that log.

## How to change how it behaves (for maintainers)

The behaviour is controlled in a few well-separated places, ordered here from
"no code, just content" to "needs a developer".

### Changing the review criteria / the AI's instructions

`config/scope_review/instructions.md` **is** the rubric the AI reads — the exact
criteria, how to weigh evidence, the calibration notes, and the author-facing
note conventions. It is fed to the model verbatim. If you want the AI to weigh
something differently (say, treat "interest in adopting" as insufficient
evidence, or be more generous to specialised-domain tools), **edit this file.**
This is the single most important knob and it needs no programming — it is prose.

**The one rule to respect:** the fast mechanical checks (repository age, presence
of tests, licence) are also encoded in code so they can run without the AI. If
you change a criterion that has a mechanical part — for example the six-month
history requirement — the instructions file *and* the code that enforces it must
change together, or they will quietly disagree. Anything that is pure judgment
(research impact, community context) lives only in the instructions file and can
be edited freely.

### Changing the author-facing rejection wording

Two sources, matching the two kinds of rejection:

- For clear mechanical desk-rejects, the templated note lives in
  `app/services/scope_review/draft_note.rb`.
- For AI-drafted notes on the judgment cases, the conventions are in the
  "Author-Facing Notes" section of `config/scope_review/instructions.md`.

Keep them consistent with each other.

### Changing thresholds, models, or turning it on and off

`config/settings-production.yml`, under `scope_review:` — a few settings, no
code:

- `enabled` — the master switch. `false` runs nothing; set `true` to let the
  scheduled sweep run.
- `triage_model` / `investigator_model` — which AI models the two AI tiers use.
- `triage_confidence_threshold` — how sure the quick tier must be before it
  finalises a decision rather than escalating to the deeper one. Lower it to
  send more cases to the (slower, costlier, more careful) investigation.
- `max_repo_size_kb`, `clone_timeout`, `history_commit_cap` — safety limits for
  very large repositories.

These take effect on the next deploy.

### Changing the mechanical checks or adding a new signal

The deterministic checks, the anomaly triggers, and the "don't auto-reject on
impact alone" cap live in code (`app/services/scope_review/`). Changing the
six-month cutoff, adding a new automatic check, or altering routing needs a
developer and a corresponding update to the instructions file and the test
suite. Treat `config/scope_review/instructions.md` as the source of truth and
derive the code from it, not the other way round.

## Rollout

The screening is introduced in shadow mode: it generates assessments silently,
you keep making decisions the way you always have, and we compare the two. Only
once agreement is demonstrably high do the drafts start being used as the basis
for real author-facing notes. Your agree/override clicks are what drive that
judgement, so they matter most in these early weeks.

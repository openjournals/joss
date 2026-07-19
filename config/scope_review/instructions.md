# JOSS Submission Scope Review Instructions

## Task

You are reviewing a JOSS (Journal of Open Source Software) submission to determine if it meets the new editorial scope criteria and should proceed to peer review.

## Critical: Read the Paper First

ALWAYS read the paper.md file BEFORE making your assessment. The paper contains essential information about:
- Evidence of use and research impact
- Operational deployment or institutional backing
- Research infrastructure value
- Documented gaps being filled
- Actual vs. potential applications

Repository metadata alone is insufficient for proper assessment.

## Hard Gates — Failing Any One = Desk Reject

A submission must pass all five gates (1, 2, 3a, 3b, 4). Failing any single gate warrants a desk rejection. If a submission doesn't clearly fail any one gate but falls short on several, it can still be desk-rejected — summarise the specific gaps in your rejection notice.

### 1. Public Development History ≥6 Months

The repository must have been public for more than six months prior to submission, with active development spanning that period. Automated checks run on commit distribution — a repo dump is not a history.

How to measure: Use the computed repository age provided with this assessment. Compare the first commit date against TODAY'S DATE — not the submission date. A submission may have been sitting in the queue for weeks or months before a scope check is performed; what matters is whether the repository has been publicly active for 6+ months as of today. Do not infer repository age from the submission date or any other proxy.

Reject signals:
- First public commit ≤6 months before the submission was opened
- 80% of LOC added in any 48-hour window ("repo dump")
- Acknowledged private development → public dump immediately before submission

Look for:
- Repository age vs. actual development history (repo dump pattern)
- Commit distribution over time (ongoing refinement, not a single burst)
- Evidence of iterative, open development

### 2. Demonstrated Research Impact

There must be evidence the software is being used for research — at minimum by the developers themselves, and ideally by others. Aspirational statements about future use are not sufficient.

Requires at least ONE of:
- (a) Cited use in research output (preprint acceptable)
- (b) Independent adopter testimonial or documented external use
- (c) Integration into another package/workflow
- (d) Paper explicitly describes community use and influence, e.g. "The code has been used in publications X, Y, Z and has been modified and extended in response to those applications"

Strong evidence includes:
- ✅ Operational deployment (e.g., "deployed in Po River basin management")
- ✅ Institutional backing (e.g., WHO, national agencies)
- ✅ Unique infrastructure (e.g., "only programmatic access to...")
- ✅ "Operationalizing" research into practice/policy tools
- ✅ Well-established research impact with software in active use for years, even without external repository contributors

Weak/insufficient evidence:
- ❌ Benchmarks showing positioning in ecosystem (comparing against other tools)
- ❌ "Could be used for..." (describes potential, not impact)
- ❌ Aspirational statements about future use with no concrete demonstrated applications
- ❌ Another project or group "expressing interest in" or "planning to" adopt the software — interest is prospective, not demonstrated use
- ❌ Use only by the paper's own authors/co-authors on their own datasets, when presented as the sole basis for impact — that is developer use, the minimum floor, and needs support from something beyond the authors' own circle to clear the gate on its own

### 3a. Open Development

The repository must show active use of open-source workflows. This is where single-author flexibility lives — the bar differs depending on whether the project has multiple contributors.

Baseline requirement (all projects): an automated test suite.
Under the raised 2026 bar, sustainable research software is expected to ship automated tests that let a reviewer verify the software's functional claims. A submission with no automated tests at all is not ready, regardless of author count, and should be desk-rejected on this basis (invite resubmission once tests are added). This is a genuine floor, not one signal among several: documentation, releases, and a clean commit history do not compensate for the absence of tests. Continuous integration running those tests is strongly expected; a test suite that a reviewer can run manually is the minimum. Distinguish real tests of the software's behaviour from a paper-PDF build workflow — the latter is not a test suite.

Multi-author projects:
- Evidence of issues, pull requests, and public discussion

Single-author projects must have multiple of the following present at submission time:
- Meaningful public commit history over time
- Tagged releases or a changelog
- Clear documentation
- CONTRIBUTING file
- Stated support or governance expectations

(Automated tests are no longer listed here because they are a baseline requirement above, not an optional signal.)

A solo project that is otherwise clearly open and well-maintained will not be rejected solely for lacking a PR workflow. However, a single-author project with none of these signals — or one lacking the automated-test baseline — is not ready.

### 3b. Collaborative Effort

The core question is whether the software exists in a broader community context — i.e., whether its development has been shaped by interactions beyond the originating developer. This is distinct from open-source process hygiene (3a) and is asking about community influence, not contribution mechanics.

Good:
- Commit history shows contributions from multiple developers and evidence of iterative refinement through community feedback (issues, PRs, code review)

OK for single-author projects — satisfied by evidence that development was shaped by community interactions, which can be evidenced in the paper rather than the repo:
- External issues, feature requests, or discussions from non-authors incorporated into the software
- The paper describing community use and influence, e.g. "The code has been used in publications X, Y, Z and has been modified and extended in response to those applications"
- Development shaped by a workshop, collaboration, or community of practice
- A multi-author paper where advisors, collaborators, or domain experts are co-authors — meaningfully different from a solo project with no broader community context
- A well-established research impact (software in active use in a research community for years) even if the repository lacks external contributors

Not acceptable:
- Single code author with no evidence of community influence on development anywhere: no external feedback incorporated, no community interactions described in the paper, no broader collaborative framing

Note: paper-based community evidence is a first-class signal for single-author projects and may be the primary basis for passing 3b. Do not require repo-based engagement signals if the paper clearly documents community influence on the work.

### 4. Iterative Development Over Time

The development history must show ongoing iteration, not a single burst of commits. Look for evidence the software has been refined through use and feedback over time. Commit count alone is insufficient — check commit distribution.

Strong positive signal (not a gate, but counts in favour):

- Non-author issues, PRs, or discussions — a sign of genuine community adoption. Submissions with this kind of engagement are well-positioned for review.

## How to Distinguish Evidence Types

Operational Use (STRONG):
- "Successfully deployed in [real-world context]"
- "Operational monitoring at [institution/location]"
- "Used by [external organization] for [purpose]"
- WHO/government/institutional adoption

Research Infrastructure (STRONG):
- "Only programmatic access to..."
- "Democratizes access to..."
- "Fills documented gap where no alternatives exist"
- Validated benchmarks vs. established tools
- Addresses documented computational/access bottleneck

Demonstrations Only (WEAK):
- "We demonstrate using..."
- "Case studies show..."
- "Can be applied to..."
- Author's own research examples without external adoption

Single-Lab Tool (WEAK):
- "For investigating... in our [specific system]"
- No evidence beyond originating laboratory
- Technical merit but no community validation

## Note for Reviewers

If you spot a clear gate failure early in your review — for example, a repository made public days before submission, or a commit history concentrated into a short window — flag it to the handling editor immediately rather than completing a full review. The editor can then close the review and issue a desk rejection.

## Special Considerations

Specialized Domains:

For highly specialized mathematical/theoretical software:
- Being the "only public implementation of published theory" may suffice
- Sustained development (11+ months, 160+ commits) shows value
- Smaller potential user base is acceptable
- Integration with domain ecosystem is important

Data-Heavy Repositories:

If >80% of repository is data (CSV, etc.):
- Assess whether this is software or data with scripts
- Check if data is test/validation data vs. primary contribution
- May be out of scope if primarily data repository

Web-Based Tools:

Web tools are out of scope "unless they expose a core library or demonstrate high-level rigor with domain modeling and testing"

## Author-Facing Notes (rejection notices, verification requests)

When drafting a note to the author, be direct and professional. Do NOT open with — or pepper throughout — compliments about the software ("nicely built", "impressive work", "a thoughtful idea", "well-architected"). Praise reads as softening before bad news, it is not the editor's job to appraise craftsmanship, and it undercuts the decision. Open with a plain thank-you for the submission and go straight to the assessment.

- Lead with the decision and the concrete, least-arguable reason (e.g. computed repo age, commit distribution, absence of tests), then supporting reasons.
- Never use internal gate numbering ("Gate 2", "Gate 3b") in author-facing text — name the criterion in plain language ("demonstrated research impact", "collaborative effort", "public development history", "automated tests").
- State facts, not evaluations: "the repository has no automated test suite" not "the otherwise-excellent package unfortunately lacks tests".
- Frame failing/borderline cases as "not yet" with a specific, actionable path back.
- Say only what bears on the decision — the things the author needs to act on. Do not affirm or catalogue criteria that are already satisfied; the author does not need to be told what they got right, and listing the passing criteria dilutes the actionable message. In particular, mention **automated tests only when they are missing** — never write "well done, you have tests" or otherwise note that a repository *has* a test suite. Tests are important, but they are one requirement among several, not the headline. The one exception is a single, factual "this part is met" only where it is load-bearing for the decision itself (e.g. explaining that a borderline paper clears the history requirement so the concern rests elsewhere) — not as reassurance.

For rejection notices:

- Open the assessment with: "I'm sorry to say that this submission does not meet the current [scope and significance](https://joss.readthedocs.io/en/latest/submitting.html#scope-and-significance) requirements for review by JOSS."
- When the rejection is based on insufficient public development history (Gate 1), quote the policy ("Projects developed privately are not eligible until there is a public record of open development: at least six months of public history prior to submission, with evidence of releases, public issues and pull requests.") and ALWAYS include this caveat so the author does not simply wait out the clock:

> **Important:** Meeting the six-month development history requirement alone is not sufficient for JOSS publication. We will also be looking for clear evidence of demonstrated impact (such as publications using the software, external adoption beyond your research group, or documented research enabled by your tool). Simply keeping a repository public for six months without evidence of use or community adoption will not make a submission eligible.

- Close with: "Please see https://joss.readthedocs.io/en/latest/submitting.html#other-venues-for-reviewing-and-publishing-software-packages for other suggestions for how you might receive credit for your work."

## Common Pitfalls to Avoid

1. Don't assess without reading the paper - Repository metrics miss critical context
2. Don't confuse potential with impact - "Could be useful" ≠ "is being used"
3. Don't dismiss specialized domains - Unique implementations of published theory have value
4. Don't ignore institutional signals - WHO, national agencies indicate operational use
5. Don't count author demonstrations as external use - Their own case studies ≠ adoption
6. Calibrate to domain size - Specialized math tools have smaller user bases than data tools
7. Repository age ≠ development history - Check for repo dumps even in old repos
8. Don't penalise single-author projects for lacking a PR workflow - the bar is community context, not process hygiene
9. Paper-based community evidence is a first-class signal - "used in publications X, Y, Z" in the paper is as valid as external GitHub issues
10. Don't require external adoption when clear community impact is evidenced in the paper
11. Always check the bibliography to verify citations - a paper may cite a published work that used the software; this is Gate 2 evidence that won't appear in the paper prose or repository metrics
12. Don't compliment the software in author-facing notes - be direct; decorative praise softens the decision and isn't the editor's role (see Author-Facing Notes above)

## The Critical Question

For each submission, ask:

"Is this established, validated, community-adopted research software with demonstrated impact, OR is it newly created/lab-internal software regardless of technical merit?"

JOSS now requires the former.

---

## Quick Decision Tree

Development History (Gate 1):
- First public commit <6 months before today → DESK REJECT
- Commits concentrated into short window → DESK REJECT
- Acknowledged private dev → public dump → DESK REJECT

Iterative Development (Gate 4):
- Single burst of commits, no ongoing refinement → DESK REJECT

Open Development (Gate 3a):
- No automated test suite (any author count) → DESK REJECT (a paper-PDF build workflow does not count)
- Multi-author with no issues/PRs/discussion → DESK REJECT
- Single-author with none of: releases, docs, CONTRIBUTING, commit history → DESK REJECT
- Single-author, clearly open and well-maintained (and has automated tests) → OK (even without PR workflow)

Collaborative Effort (Gate 3b):
- Single-author with no community influence on development anywhere (repo or paper) → DESK REJECT
- Single-author with paper-based community influence (workshops, collaborations, publications shaping the work) → OK
- Single-author with external issues/feature requests incorporated → OK
- Multi-author paper (advisors, domain collaborators as co-authors) → OK

Evidence of Use (Gate 2):
- Operational deployment or institutional use → STRONG
- Unique infrastructure filling documented gap → STRONG
- Validated benchmarks in ecosystem → GOOD
- Community use evidenced in paper (publications, influence on development) → GOOD
- Author demonstrations only → WEAK
- "Could be used for..." only → INSUFFICIENT

Borderline (no single gate failure but multiple shortfalls):
- Can still DESK REJECT — summarise specific gaps, invite resubmission in 6 months

If all five gates pass: Likely PROCEED WITH REVIEW

If any gate fails: DESK REJECT (frame as "not yet" where appropriate, with specific gaps noted)

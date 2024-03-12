# Editorial Guide

The Journal of Open Source Software (JOSS) conducts all peer review and editorial processes in the open, on the GitHub issue tracker.

JOSS editors manage the review workflow with the help of our bot, `@editorialbot`. The bot is summoned with commands typed directly on the GitHub review issues. For a list of commands, type: `@editorialbot commands`.

```{note}
To learn more about `@editorialbot`'s functionalities, take a look at our [dedicated guide](editorial_bot).
```

## Overview of editorial process

**Step 1: An author submits a paper.**

The author can choose to select an preferred editor based on the information available in our biographies. This can be changed later.

**Step 2: If you are selected as an editor you get @-mentioned in the pre-review issue.**

This doesn’t mean that you’re the editor, just that you’ve been suggested by the author.

**Step 3: Once you are the editor, find the link to the code repository in the `pre-review` issue**

- If the paper is not in the default branch, add it to the issue with the command: `@editorialbot set branch-where-paper-is as branch`.

**Step 4: The editor looks at the software submitted and checks to see if:**

- There’s a general description of the software
- The software is within scope as research software
- It has an OSI-approved license

**Step 5: The editor responds to the author saying that things look in line (or not) and will search for reviewer**

**Step 6: The editor finds >= 2 reviewers**

- Use the list of reviewers: type the command `@editorialbot list reviewers` or
  look at use the [Reviewers Management System](https://reviewers.joss.theoj.org)
- If people are in the review list, the editor can @-mention them on the issue to see if they will review: e.g. `@person1 @person2 can you review this submission for JOSS?`
- Or solicit reviewers outside the list. Send an email to people describing what JOSS is and asking if they would be interested in reviewing.
- If you ask the author to suggest potential reviewers, please be sure to tell the author not to @-tag their suggestions.

**Step 7: Editor tells EditorialBot to assign the reviewers to the paper**

- Use `@editorialbot add @reviewer as reviewer`
- To add a second reviewer use `@editorialbot add @reviewer2 as reviewer`

**Step 8: Create the actual review issue**

- Use `@editorialbot start review`
- An issue is created with the review checklist, one per reviewer, e.g. https://github.com/openjournals/joss-reviews/issues/717

**Step 9: Close the pre-review issue**

**Step 10: The actual JOSS review**

- The reviewer reviews the paper and has a conversation with the author. The editor lurks on this conversation and comes in if needed for questions (or CoC issues).
- The reviewer potentially asks for changes and the author makes changes. Everyone agrees it’s ready.

**Step 11: The editor pings the EiC team to get the paper published**

- Make a final check of the paper with `@editorialbot generate pdf` and that all references have DOIs (where appropriate) with `@editorialbot check references`.
- If everything looks good, ask the author to make a new release (if possible) of the software being reviewed and deposit a new archive the software with Zenodo/figshare. Update the review thread with this archive DOI: `@editorialbot set 10.5281/zenodo.xxxxxx as archive`.
- Editors can get a checklist of the final steps using the `@editorialbot create post-review checklist` command
- Finally, use `@editorialbot recommend-accept` on the review thread to ping the `@openjournals/joss-eics` team letting them know the paper is ready to be accepted.

**Step 12: Celebrate publication! Tweet! Thank reviewers! Say thank you on issue.**

### Visualization of editorial flow

![Editorial flow](images/JOSS-flowchart.png)


## Pre-review

Once a submission comes in, it will be in the queue for a quick check by the Track Editor-in-chief (TEiC). From there, it moves to a `PRE-REVIEW` issue, where the TEiC will assign a handling editor, and the author can suggest reviewers. Initial direction to the authors for improving the paper can already happen here, especially if the paper lacks some requested sections.

```{important}
If the paper is out-of-scope for JOSS, editors assess this and notify the author in the ``PRE-REVIEW`` issue.
```

Editors can flag submissions of questionable scope using the command `@editorialbot query scope`.

The TEiC assigns an editor (or a volunteering editor self-assigns) with the command `@editorialbot assign @username as editor` in a comment.

```{note}
Please check in on the [dashboard](https://joss.theoj.org/dashboard/incoming) semi-regularly to see which papers are currently without an editor, and if possible, volunteer to edit papers that look to be in your domain. If you choose to be an editor in the issue thread type the command `@editorialbot assign @yourhandle as editor` or simply `@editorialbot assign me as editor`
```

### How papers are assigned to editors

By default, unless an editor volunteers, the Track Editor-in-chief (TEiC) on duty will attempt to assign an incoming paper to the most suitable handling editor. While TEiC will make every effort to match a submission with the most appropriate editor, there are a number of situations where an TEiC may assign a paper to an editor that doesn't fit entirely within the editor's research domains:

- If there's no obvious fit to _any_ of the JOSS editors
- If the most suitable editor is already handling a large number of papers
- If the chosen editor has a lighter editorial load than other editors

In most cases, the TEiC will ask one or more editors to edit a submission (e.g. `@editor1, @editor 2 - would one of you be willing to edit this submission for JOSS`). If the editor doesn't respond within ~3 working days, the TEiC may assign the paper to the editor regardless.

Editors may also be invited to edit over email when an TEiC runs the command `@editorialbot invite @editor1 as editor`.

### Finding reviewers

At this point, the handling editor's job is to identify reviewers who have sufficient expertise in the field of software and in the field of the submission. JOSS papers have to have a minimum of two reviewers per submission, except for papers that have previously been peer-reviewed via rOpenSci. In some cases, the editor also might want to formally add themselves as one of the reviewers. If the editor feels particularly unsure of the submission, a third (or fourth) reviewer can be recruited.

To recruit reviewers, the handling editor can mention them in the `PRE-REVIEW` issue with their GitHub handle, ping them on Twitter, or email them. After expressing initial interest, candidate reviewers may need a longer explanation via email. See sample reviewer invitation email, below.

**Reviewer Considerations**

- It is rare that all reviewers have the expertise to cover all aspects of a submission (e.g., knows the language really well and knows the scientific discipline well). As such, a good practice is to try and make sure that between the two or three reviewers, all aspects of the submission are covered.
- Selection and assignment of reviewers should adhere to the [JOSS COI policy](https://joss.theoj.org/about#ethics).

**Potential ways to find reviewers**

Finding reviewers can be challenging, especially if a submission is outside of your immediate area of expertise. Some strategies you can use to identify potential candidates:

- Search the [reviewer application](https://reviewers.joss.theoj.org) of volunteer reviewers.
  - When using this spreadsheet, pay attention to the number of reviews this individual is already doing to avoid overloading them.
  - It can be helpful to use the "Data > Filter Views" capability to temporarily filter the table view to include only people with language or domain expertise matching the paper.
- Ask the author(s): You are free to ask the submitting author to suggest possible reviewers by using the [reviewer application](https://reviewers.joss.theoj.org) and also people from their professional network. In this situation, the editor still needs to verify that their suggestions are appropriate.
- Use your professional network: You're welcome to invite people you know of who might be able to give a good review.
- Search Google and GitHub for related work, and write to the authors of that related work.
  - You might like to try [this tool](https://github.com/dfm/joss-reviewer) from @dfm.
- Ask on social networks: Sometimes asking on Twitter for reviewers can identify good candidates.
- Check the work being referenced in the submission:
  - Authors of software that is being built on might be interested in reviewing the submission.
  - Users of the software that is being submission be interested in reviewing the submission
- Avoid asking JOSS editors to review: If at all possible, avoid asking JOSS editors to review as they are generally very busy editing their own papers.

Once a reviewer accepts, the handling editor runs the command `@editorialbot add @username as reviewer` in the `PRE-REVIEW` issue. Add more reviewers with the same command.
Under the uncommon circumstance that a review must be started before all reviewers have been identified (e.g., if finding a second reviewer is taking a long time and the first reviewer wants to get started), an editor may elect to start the review and add the remaining reviewers later. To accomplish this, the editor will need to hand-edit the review checklist to create space for the reviewers added after the review issues is created.

### Starting the review

Next, run the command `@editorialbot start review`. If you haven't assigned an editor and reviewer, this command will fail and `@editorialbot` will tell you this. This will open the `REVIEW` issue, with prepared review checklists for each reviewer, and instructions. The editor should move the conversation to the separate `REVIEW` issue.

## Review

The `REVIEW` issue contains some instructions for the reviewers to get a checklist using the command `@editorialbot generate my checklist`. The reviewer(s) should check off items of the checklist one-by-one, until done. In the meantime, reviewers can engage the authors freely in a conversation aimed at improving the paper.

If a reviewer recants their commitment or is unresponsive, editors can remove them with the command `@editorialbot remove @username from reviewers`. You can also add new reviewers in the `REVIEW` issue.

Comments in the `REVIEW` issue should be kept brief, as much as possible, with more lengthy suggestions or requests posted as separate issues, directly in the submission repository. A link-back to those issues in the `REVIEW` is helpful.

When the reviewers are satisfied with the improvements, we ask that they confirm their recommendation to accept the submission.

### Adding a new reviewer once the review has started

Sometimes you'll need to add a new reviewer once the main review (i.e. post pre-review) is already underway. In this situation you should do the following:

- In the review thread, do `@editorialbot add @newreviewer as reviewer`.
- The new reviewer must use the command `@editorialbot generate my checklist` to get a checklist.


## Post-review

When a submission is ready to be accepted, we ask that the authors issue a new tagged release of the software (if changed), and archive it (on [Zenodo](https://zenodo.org/), [fig**share**](https://figshare.com/), or other). The authors then post the version number and archive DOI in the `REVIEW` issue. The handling editor executes the pre-publication steps, and pings the Track Editor-in-Chief for final processing.

Optionally you can ask EditorialBot to generate a checklist with all the post-review steps running the command: `@editorialbot create post-review checklist`

Pre-publication steps:
- Get a new proof with the `@editorialbot generate pdf` command.
- Download the proof, check all references have DOIs, follow the links and check the references.
  - EditorialBot can help check references with the command `@editorialbot check references`
- Proof-read the paper and ask authors to fix any remaining typos, badly formed citations, awkward wording, etc..
- Ask the author to make a tagged release and archive, and report the version number and archive DOI in the review thread.
- Check the archive deposit has the correct metadata (title and author list), and request the author edit it if it doesn’t match the paper.
- Run `@editorialbot set <doi> as archive`.
- Run `@editorialbot set <v1.x.x> as version` if the version was updated.
- Run `@editorialbot recommend-accept` to generate the final proofs, which has EditorialBot notify the `@openjournals/joss-eics` team that the paper is ready for final processing.

At this point, the EiC/AEiC will take over to make final checks and publish the paper.

It’s also a good idea to ask the authors to check the proof. We’ve had a few papers request a post-publication change of author list, for example—this requires a manual download/compile/deposit cycle and should be a rare event.


## Rejecting a paper

If you believe a submission should be rejected, for example, because it is out of scope for JOSS, then you should:

- Ask EditorialBot to flag the submission as potentially out of scope with the command `@editorialbot query scope`. This command adds the `query-scope` label to the issue.
- Mention to the author your reasons for flagging the submission as possibly out of scope, and _optionally_ give them an opportunity to defend their submission.
- During the scope review process, the editorial team may ask the authors to provide additional information about their submission to assist the editorial board with their decision.
- The TEiC will make a final determination of whether a submission is in scope, taking into account the feedback of other editors.

**Scope reviews for resubmissions**

In the event that an author re-submits a paper to JOSS that was previously rejected, the TEiC will use their discretion to determine: 1) whether a full scope review by the entire editorial team is necessary, 2) if the previous reasons for rejection remain valid, or 3) if there have been enough updates to warrant sending the submission out for review.

## JOSS Collaborations

### AAS publishing

JOSS is collaborating with [AAS publishing](https://journals.aas.org/) to offer software review for some of the papers submitted to their journals. A detailed overview of the motivations/background is available in the [announcement blog post](https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing), here we document the additional editorial steps that are necessary for JOSS to follow:

**Before/during review**

- If the paper is a joint publication, make sure you apply the [`AAS`](https://github.com/openjournals/joss-reviews/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3AAAS+) label to both the `pre-review` and the `review` issues.
- Before moving the JOSS paper from `pre-review` to `review`, ensure that you (the JOSS editor) make the reviewers aware that JOSS will be receiving a small financial donation from AAS publishing for this review (e.g. [like this](https://github.com/openjournals/joss-reviews/issues/1852#issuecomment-553203738)).

**After the paper has been accepted by JOSS**

- Once the JOSS review is complete, ask the author for the status of their AAS publication, specifically if they have the AAS paper DOI yet.
- Once this is available, ask the author to add this information to their `paper.md` YAML header as documented in the [submission guidelines](paper.md#what-should-my-paper-contain).

```
# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
aas-journal: Astrophysical Journal <- The name of the AAS journal.
```

- Pause the review (by applying the `paused` label) to await notification that the AAS paper is published.

**Once the AAS paper is published**

- Ask the EiC on rotation to publish the paper as normal (by tagging `@openjournals/joss-eics`).

### rOpenSci-reviewed or pyOpenSci-reviewed and accepted submissions

If a paper has already been reviewed and accepted by rOpenSci or pyOpenSci, the streamlined JOSS review process is:

- Assign yourself as editor and reviewer
- Add a comment in the pre-review issue pointing to the rOpenSci or pyOpenSci review
- Add the rOpenSci/pyOpenSci label to the pre-review issue
- Start the review issue
- Add a comment in the review issue pointing to the rOpenSci or pyOpenSci review
- Compile the paper and check it looks OK
- Go to to the source code repo and grab the Zenodo DOI
- Accept and publish the paper






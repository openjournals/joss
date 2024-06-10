# Sample messages for authors and reviewers

## Sample email to potential reviewers

```
Dear Dr. Jekyll,

I found you following links from the page of The Super Project and/or on Twitter. This
message is to ask if you can help us out with a submission to JOSS (The Journal of Open
Source Software, https://joss.theoj.org), where I’m an editor.

JOSS publishes articles about open source research software. The submission I'd like you
to review is titled: "great software name here"

and the submission repository is at: https://github.com/< … >

JOSS is a free, open-source, community driven and developer-friendly online journal
(no publisher is seeking to raise revenue from the volunteer labor of researchers!).

The review process at JOSS is unique: it takes place in a GitHub issue, is open,
and author-reviewer-editor conversations are encouraged.

JOSS reviews involve downloading and installing the software, and inspecting the repository
and submitted paper for key elements. See https://joss.readthedocs.io/en/latest/review_criteria.html

Editors and reviewers post comments on the Review issue, and authors respond to the comments
and improve their submission until acceptance (or withdrawal, if they feel unable to
satisfy the review).

Would you be able to review this submission for JOSS? If not, can you recommend
someone from your team to help out?

Kind regards,

JOSS Editor.
```

## Query scope of submission

```
:wave: thanks for your submission to JOSS. From a quick inspection of this submission it's not entirely obvious that it meets our [submission criteria](https://joss.readthedocs.io/en/latest/submitting.html#submission-requirements). In particular, this item:

> - Your software should have an obvious research application

Could you confirm here that there _is_ a research application for this software (and explain what that application is)? The section [_'what should my paper contain'_](https://joss.readthedocs.io/en/latest/paper.html#what-should-my-paper-contain) has some guidance for the sort of content we're looking to be present in the `paper.md`.

Many thanks!
```

## GitHub invite to potential reviewers

```
:wave: @reviewer1 & @reviewer2, would any of you be willing to review this submission for JOSS? We carry out our checklist-driven reviews here in GitHub issues and follow these guidelines: https://joss.readthedocs.io/en/latest/review_criteria.html
```

## Message to reviewers at the start of a review

```
👋🏼 @authorname @reviewer1 @reviewer2 this is the review thread for the paper. All of our communications will happen here from now on.

As a reviewer, the first step is to create a checklist for your review by entering

```@editorialbot generate my checklist```

as the top of a new comment in this thread.

These checklists contain the JOSS requirements. As you go over the submission, please check any items that you feel have been satisfied. The first comment in this thread also contains links to the JOSS reviewer guidelines.

The JOSS review is different from most other journals. Our goal is to work with the authors to help them meet our criteria instead of merely passing judgment on the submission. As such, the reviewers are encouraged to submit issues and pull requests on the software repository. When doing so, please mention `openjournals/joss-reviews#REVIEW_NUMBER` so that a link is created to this thread (and I can keep an eye on what is happening). Please also feel free to comment and ask questions on this thread. In my experience, it is better to post comments/questions/suggestions as you come across them instead of waiting until you've reviewed the entire package.

We aim for reviews to be completed within about 2-4 weeks. Please let me know if any of you require some more time. We can also use EditorialBot (our bot) to set automatic reminders if you know you'll be away for a known period of time.

Please feel free to ping me (@editorname) if you have any questions/concerns.
```

## Message to authors at the end of a review

```
At this point could you:
- Make a tagged release of your software, and list the version tag of the archived version here.
- Archive the reviewed software in Zenodo or a similar service (e.g., figshare, an institutional repository)
- Check the archival deposit (e.g., in Zenodo) has the correct metadata. This includes the title (should match the paper title) and author list (make sure the list is correct and people who only made a small fix are not on it). You may also add the authors' ORCID.
- Please list the DOI of the archived version here.

I can then move forward with recommending acceptance of the submission.
```

## Rejection due to out of scope/failing substantial scholarly effort test

(Note that rejections are handled by EiCs and not individual editors).

```
@authorname - thanks for your submission to JOSS. Unfortunately, after review by the JOSS editorial team we've determined that this submission doesn't meet our [substantial scholarly effort](https://joss.readthedocs.io/en/latest/submitting.html#substantial-scholarly-effort) criterion.

One possible alternative to JOSS is to follow [GitHub's guide](https://guides.github.com/activities/citable-code/) on how to create a permanent archive and DOI for your software. This DOI can then be used by others to cite your work.
```

# Submitting a paper to JOSS

If you've already developed a fully featured research code, released it under an [OSI-approved license](https://opensource.org/licenses), and written good documentation and tests, then we expect that it should take perhaps an hour or two to prepare and submit your paper to JOSS.
But please read these instructions carefully for a streamlined submission.

## Submission requirements

- The software must be open source as per the [OSI definition](https://opensource.org/osd).
- The software must be hosted at a location where users can open issues and propose code changes without manual approval of (or payment for) accounts.
- The software must have an **obvious** research application.
- You must be a major contributor to the software you are submitting, and have a GitHub account to participate in the review process.
- Your paper must not focus on new research results accomplished with the software.
- Your paper (`paper.md` and BibTeX files, plus any figures) must be hosted in a Git-based repository together with your software.
- The paper may be in a short-lived branch which is never merged with the default, although if you do this, make sure this branch is _created_ from the default so that it also includes the source code of your submission.

In addition, the software associated with your submission must:

- Be stored in a repository that can be cloned without registration.
- Be stored in a repository that is browsable online without registration.
- Have an issue tracker that is readable without registration.
- Permit individuals to create issues/file tickets against your repository.

### What we mean by research software

JOSS publishes articles about research software. This definition includes software that: solves complex modeling problems in a scientific context (physics, mathematics, biology, medicine, social science, neuroscience, engineering); supports the functioning of research instruments or the execution of research experiments; extracts knowledge from large data sets; offers a mathematical library, or similar. While useful for many areas of research, pre-trained machine learning models and notebooks are not in-scope for JOSS. 

### Substantial scholarly effort

JOSS publishes articles about software that represent substantial scholarly effort on the part of the authors. Your software should be a significant contribution to the available open source software that either enables some new research challenges to be addressed or makes addressing research challenges significantly better (e.g., faster, easier, simpler).

As a rule of thumb, JOSS' minimum allowable contribution should represent **not less than** three months of work for an individual. Some factors that may be considered by editors and reviewers when judging effort include:

- Age of software (is this a well-established software project) / length of commit history.
- Number of commits.
- Number of authors.
- Total lines of code (LOC). Submissions under 1000 LOC will usually be flagged, those under 300 LOC will be desk rejected.
- Whether the software has already been cited in academic papers.
- Whether the software is sufficiently useful that it is _likely to be cited_ by your peer group.

In addition, JOSS requires that software should be feature-complete (i.e., no half-baked solutions), packaged appropriately according to common community standards for the programming language being used (e.g., [Python](https://packaging.python.org), [R](https://r-pkgs.org/index.html)), and designed for maintainable extension (not one-off modifications of existing tools). "Minor utility" packages, including "thin" API clients, and single-function packages are not acceptable.

#### A note on web-based software

Many web-based research tools are out of scope for JOSS due to a lack of modularity and challenges testing and maintaining the code. Web-based tools may be considered 'in scope' for JOSS, provided that they meet one or both of the following criteria: 1) they are are built around and expose a 'core library' through a web-based experience (e.g., R/[Shiny](https://www.rstudio.com/products/shiny/) applications) or 2) the web application demonstrates a high-level of rigor with respect to domain modeling and testing (e.g., adopts and implements a design pattern such as [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) using a framework such as [Django](https://www.djangoproject.com/)).

Similar to other categories of submission to JOSS, it's essential that any web-based tool can be tested easily by reviewers locally (i.e., on their local machine). 

### Co-publication of science, methods, and software

Sometimes authors prepare a JOSS publication alongside a contribution describing a science application, details of algorithm development, and/or methods assessment. In this circumstance, JOSS considers submissions for which the implementation of the software itself reflects a substantial scientific effort. This may be represented by the design of the software, the implementation of the algorithms, creation of tutorials, or any other aspect of the software. We ask that authors indicate whether related publications (published, in review, or nearing submission) exist as part of submitting to JOSS.

#### Other venues for reviewing and publishing software packages

Authors wishing to publish software deemed out of scope for JOSS have a few options available to them:

- Follow [GitHub's guide](https://guides.github.com/activities/citable-code/) on how to create a permanent archive and DOI for your software. This DOI can then be used by others to cite your work.
- Enquire whether your software might be considered by communities such as [rOpenSci](https://ropensci.org) and [pyOpenSci](https://pyopensci.org).

### Should I write my own software or contribute to an existing package?

While we are happy to review submissions in standalone repositories, we also review submissions that are significant contributions made to existing packages. It is often better to have an integrated library or package of methods than a large number of single-method packages.

## Policies

**Disclosure:** All authors must disclose any potential conflicts of interest related to the research in their manuscript, including financial, personal, or professional relationships that may affect their objectivity. This includes any financial relationships, such as employment, consultancies, honoraria, stock ownership, or other financial interests that may be relevant to the research.

**Acknowledgement:** Authors should acknowledge all sources of financial support for the work and include a statement indicating whether or not the sponsor had any involvement in it.

**Review process:** Editors and reviewers must be informed of any potential conflicts of interest before reviewing the manuscript to ensure unbiased evaluation of the research.

**Compliance:** Authors who fail to comply with the COI policy may have their manuscript rejected or retracted if a conflict is discovered after publication.

**Review and Update:** This COI policy will be reviewed and updated regularly to ensure it remains relevant and effective.

### Conflict of Interest policy for authors

An author conflict of interest (COI) arises when an author has financial, personal, or other interests that may influence their research or the interpretation of its results. In order to maintain the integrity of the work published in JOSS, we require that authors disclose any potential conflicts of interest at submission time.

### Preprint Policy

Authors are welcome to submit their papers to a preprint server ([arXiv](https://arxiv.org/), [bioRxiv](https://www.biorxiv.org/), [SocArXiv](https://socopen.org/), [PsyArXiv](https://psyarxiv.com/) etc.) at any point before, during, or after the submission and review process.

Submission to a preprint server is _not_ considered a previous publication.

### Authorship

Purely financial (such as being named on an award) and organizational (such as general supervision of a research group) contributions are not considered sufficient for co-authorship of JOSS submissions, but active project direction and other forms of non-code contributions are. The authors themselves assume responsibility for deciding who should be credited with co-authorship, and co-authors must always agree to be listed. In addition, co-authors agree to be accountable for all aspects of the work, and to notify JOSS if any retraction or correction of mistakes are needed after publication.

### Submissions using proprietary languages/development environments

We strongly prefer software that doesn't rely upon proprietary (paid for) development environments/programming languages. However, provided _your submission meets our requirements_ (including having a valid open source license) then we will consider your submission for review. Should your submission be accepted for review, we may ask you, the submitting author, to help us find reviewers who already have the required development environment installed.

## Submission Process

Before you submit, you should:

- Make your software available in an open repository (GitHub, Bitbucket, etc.) and include an [OSI approved open source license](https://opensource.org/licenses).
- Make sure that the software complies with the [JOSS review criteria](review_criteria). In particular, your software should be full-featured, well-documented, and contain procedures (such as automated tests) for checking correctness.
- Write a short paper in Markdown format using `paper.md` as file name, including a title, summary, author names, affiliations, and key references. See our [example paper](example_paper) to follow the correct format.
- (Optional) create a metadata file describing your software and include it in your repository. We provide [a script](https://gist.github.com/arfon/478b2ed49e11f984d6fb) that automates the generation of this metadata.

### Submitting your paper

Submission is as simple as:

- Filling in the [short submission form](http://joss.theoj.org/papers/new)
- Waiting for the managing editor to start a pre-review issue over in the JOSS reviews repository: https://github.com/openjournals/joss-reviews

### No submission fees

There are no fees for submitting or publishing in JOSS. You can read more about our [cost and sustainability model](http://joss.theoj.org/about#costs).

## Review Process

After submission:

- An Associate Editor-in-Chief will carry out an initial check of your submission, and proceed to assign a handling editor.
- The handling editor will assign two or more JOSS reviewers, and the review will be carried out in the [JOSS reviews repository](https://github.com/openjournals/joss-reviews).
- Authors will respond to reviewer-raised issues (if any are raised) on the submission repository's issue tracker. Reviewer and editor contributions, like any other contributions, should be acknowledged in the repository. 
- **JOSS reviews are iterative and conversational in nature.** Reviewers are encouraged to post comments/questions/suggestions in the review thread as they arise, and authors are expected to respond in a timely fashion.
- Authors and reviewers are asked to be patient when waiting for a response from an editor. Please allow a week for an editor to respond to a question before prompting them for further action.
- Upon successful completion of the review, authors will make a tagged release of the software, and deposit a copy of the repository with a data-archiving service such as [Zenodo](https://zenodo.org/) or [figshare](https://figshare.com/), get a DOI for the archive, and update the review issue thread with the version number and DOI.
- After we assign a DOI for your accepted JOSS paper, its metadata is deposited with CrossRef and listed on the JOSS website.
- The review issue will be closed, and automatic posts from [@JOSS_TheOJ at Twitter](https://twitter.com/JOSS_TheOJ) and [@JOSS at Mastodon](https://fosstodon.org/@joss) will announce it!

If you want to learn more details about the review process, take a look at the [reviewer guidelines](reviewer_guidelines).

## Confidential requests

Please write admin@theoj.org with confidential matters such as retraction requests, report of misconduct, and retroactive author name changes.

In the event of a name change request, the DOI will remain unchanged, and the paper will be updated without the publication of a correction notice. Please note that because JOSS submissions are managed publicly, updates to papers are visible in the public record (e.g., in the [JOSS papers repository](https://github.com/openjournals/joss-papers) commit history).

JOSS will also update Crossref metadata.

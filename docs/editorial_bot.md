Interacting with EditorialBot
=============================

The Open Journals' editorial bot or `@editorialbot` on GitHub, is our editorial bot that interacts with authors, reviewers, and editors on JOSS reviews.

`@editorialbot` can do a bunch of different things. If you want to ask `@editorialbot` what it can do, simply type the following in a JOSS `review` or `pre-review` issue:


```text
@editorialbot commands
```

## Author and reviewers commands

A subset of the EditorialBot commands are available to authors and reviewers:

### Compiling papers

When a `pre-review` or `review` issue is opened, `@editorialbot` will try to compile the JOSS paper by looking for a `paper.md` file in the repository specified when the paper was submitted.

If it can't find the `paper.md` file it will say as much in the review issue. If it can't compile the paper (i.e. there's some kind of Pandoc error), it will try and report that error back in the thread too.

```eval_rst
.. note:: To compile the papers ``@editorialbot`` is running this `Docker image <https://github.com/openjournals/inara>`_.
```

Anyone can ask `@editorialbot` to compile the paper again (e.g. after a change has been made). To do this simply comment on the review thread as follows:

```text
@editorialbot generate pdf
```

#### Compiling papers from a specific branch

By default, EditorialBot will look for papers in the branch set in the body of the issue (or in the default git branch if none is present). If you want to compile a paper from a specific branch (for instance: `my-custom-branch-name`), change that value with:

```text
@editorialbot set my-custom-branch-name as branch
```

And then compile the paper normally:

```text
@editorialbot generate pdf
```

#### Compiling preprint files

If you need a generic paper file suitable for preprint servers (arXiv-like) you can use the following command that will generate a LaTeX file:

```text
@editorialbot generate preprint
```

### Finding reviewers

Sometimes submitting authors suggest people the think might be appropriate to review their submission. If you want the link to the current list of JOSS reviewers, type the following in the review thread:

```text
@editorialbot list reviewers
```

## Reviewers checklist command

Once a user is assigned as reviewer and the review has started, the reviewer must type the following to get a review checklist:

```text
@editorialbot generate my checklist
```

## Editorial commands

Most of `@editorialbot`'s functionality can only be used by the journal editors.

### Assigning an editor

Editors can either assign themselves or other editors as the editor of a submission as follows:

```text
@editorialbot assign @editorname as editor
```

### Inviting an editor

EditorialBot can be used by EiCs to send email invites to registered editors as follows:

```text
@editorialbot invite @editorname as editor
```

This will send an automated email to the editor with a link to the GitHub `pre-review` issue.

### Adding and removing reviewers

Reviewers should be assigned by using the following commands:

```text
# Add a GitHub user to the reviewers of this submission
@editorialbot add @username as reviewer
or
@editorialbot add @username to reviewers

# Remove a GitHub user from the reviewers of this submission
@editorialbot remove @username from reviewers
```

### Starting the review

Once the reviewer(s) and editor have been assigned in the `pre-review` issue, the editor starts the review with:

```text
@editorialbot start review
```

```eval_rst
.. important:: If a reviewer recants their commitment or is unresponsive, editors can remove them with the command ``@editorialbot remove @username from reviewers``. You can then delete that reviewer's checklist. You can also add new reviewers in the ``REVIEW`` issue with the command ``@editorialbot add @username to reviewers``.
```

### Reminding reviewers and authors

EditorialBot can remind authors and reviewers after a specified amount of time to return to the review issue. Reminders can only be set by editors, and only for REVIEW issues. For example:

```text
# Remind the reviewer in two weeks to return to the review
@editorialbot remind @reviewer in two weeks
```

```text
# Remind the reviewer in five days to return to the review
@editorialbot remind @reviewer in five days
```

```text
# Remind the author in two weeks to return to the review
@editorialbot remind @author in two weeks
```

```eval_rst
.. note:: Most units of times are understood by EditorialBot e.g. `hour/hours/day/days/week/weeks`.
```

### Setting the software archive

When a submission is accepted, we ask that the authors to create an archive (on [Zenodo](https://zenodo.org/), [fig**share**](https://figshare.com/), or other) and post the archive DOI in the `REVIEW` issue. The editor should ask `@editorialbot` to add the archive to the issue as follows:

```text
@editorialbot set 10.0000/zenodo.00000 as archive
```

### Changing the software version

Sometimes the version of the software changes as a consequence of the review process. To update the version of the software do the following:

```text
@editorialbot set v1.0.1 as version
```

### Changing the git branch

Sometimes the paper-md file is located in a topic branch. In order to have the PDF compiled from that branch it should be added to the issue. To update the branch value do the following (in the example, the name of the topic branch is _topic-branch-name_):

```text
@editorialbot set topic-branch-name as branch
```

### Changing the repository

Sometimes authors will move their software repository during the review. To update the value of the repository URL do the following:

```text
@editorialbot set https://github.com/ORG/REPO as repository
```


### Check references

Editors can ask EditorialBot to check if the DOIs in the bib file are valid with the command:

```text
@editorialbot check references
```

```eval_rst
.. note:: EditorialBot can verify that DOIs resolve, but cannot verify that the DOI associated with a paper is actually correct. In addition, DOI suggestions from EditorialBot are just that - i.e. they may not be correct.
```

### Repository checks

A series of checks can be run on the submitted repository with the command:

```text
@editorialbot check repository
```

EditorialBot will report back with an analysis of the source code and list authorship, contributions and file types information. EditorialBot will also detect the languages used in the repository, will count the number of words in the paper file and will look for an Open Source License and for a *Statement of need* section in the paper.

It is possible to run the checks on a specific git branch:

```text
@editorialbot check repository from branch <custom-branch-name>
```

### Post-review checklist

Editors can get a checklist to remind all steps to do after the reviewers have finished their reviews and recommended the paper for acceptance:

```text
@editorialbot create post-review checklist
```

### Flag a paper with query-scope

Editors can flag a paper with query-scope with the command:

```text
@editorialbot query scope
```

### Recommending a paper for acceptance

JOSS topic editors can recommend a paper for acceptance and ask for the final proofs to be created by EditorialBot with the following command:

```text
@editorialbot recommend-accept
```

On issuing this command, EditorialBot will also check the references of the paper for any missing DOIs.


## EiC-only commands

Only the JOSS editors-in-chief can accept, reject or withdraw papers.

### Accepting a paper

If everything looks good with the draft proofs from the `@editorialbot recommend acceptance` command, JOSS editors-in-chief can take the additional step of actually accepting the JOSS paper with the following command:

```text
@editorialbot accept
```

EditorialBot will accept the paper, assign it a DOI, deposit it and publish the paper.

### Updating an already accepted paper

If the draft has been updated after a paper has been published, JOSS editors-in-chief can update the published info and PDF with the following command:

```text
@editorialbot reaccept
```

EditorialBot will update the published paper and re-deposit it.


### Rejecting a paper

JOSS editors-in-chief can reject a submission with the following command:

```text
@editorialbot reject
```

### Withdrawing a paper

JOSS editors-in-chief can withdraw a submission with the following command:

```text
@editorialbot withdraw
```

## The complete list of available commands

```

# List all available commands
@editorialbot commands

# Add to this issue's reviewers list
@editorialbot add @username as reviewer

# Remove from this issue's reviewers list
@editorialbot remove @username from reviewers

# Get a list of all editors's GitHub handles
@editorialbot list editors

# Assign a user as the editor of this submission
@editorialbot assign @username as editor

# Remove the editor assigned to this submission
@editorialbot remove editor

# Remind an author or reviewer to return to a review after a
# certain period of time (supported units days and weeks)
@editorialbot remind @reviewer in 2 weeks

# Check the references of the paper for missing DOIs
@editorialbot check references

# Perform checks on the repository
@editorialbot check repository

# Adds a checklist for the reviewer using this command
@editorialbot generate my checklist

# Set a value for version
@editorialbot set v1.0.0 as version

# Set a value for archive
@editorialbot set 10.21105/zenodo.12345 as archive

# Set a value for branch
@editorialbot set joss-paper as branch

# Set a value for repository
@editorialbot set https://github.com/org/repo as repository

# Invite an editor to edit a submission (sending them an email)
@editorialbot invite @(.*) as editor

# Generates the pdf paper
@editorialbot generate pdf

# Generates a LaTeX preprint file
@editorialbot generate preprint

# Creates a post-review checklist with editor and authors tasks
@editorialbot create post-review checklist

# Recommends the submission for acceptance
@editorialbot recommend-accept

# Accept and publish the paper
@editorialbot accept

# Update an accepted paper
@editorialbot reaccept

# Reject paper
@editorialbot reject

# Withdraw paper
@editorialbot withdraw

# Flag submission with questionable scope
@editorialbot query scope

# Get a link to the complete list of reviewers
@editorialbot list reviewers

# Open the review issue
@editorialbot start review

# Ping the EiCs for the current track
@editorialbot ping track-eic

```

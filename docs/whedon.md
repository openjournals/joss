Interacting with Whedon
========================

Whedon or `@whedon` on GitHub, is our editorial bot that interacts with authors, reviewers, and editors on JOSS reviews.

`@whedon` can do a bunch of different things. If you want to ask `@whedon` what he can do, simply type the following in a JOSS `review` or `pre-review` issue:

```text
@whedon commands
```

This will return an output something like this:

```text
# List all of Whedon's capabilities
@whedon commands

# Assign a GitHub user as the sole reviewer of this submission
@whedon assign @username as reviewer

# Add a GitHub user to the reviewers of this submission
@whedon add @username as reviewer

# Remove a GitHub user from the reviewers of this submission
@whedon remove @username as reviewer

# List of editor GitHub usernames
@whedon list editors

# List of reviewers together with programming language preferences and domain expertise
@whedon list reviewers

# Change editorial assignment
@whedon assign @username as editor

# Set the software archive DOI at the top of the issue e.g.
@whedon set 10.0000/zenodo.00000 as archive

# Open the review issue
@whedon start review

🚧 🚧 🚧 Experimental Whedon features 🚧 🚧 🚧

# Compile the paper
@whedon generate pdf
```

## Author commands

### Compiling papers

When a `pre-review` or `review` issue is opened, `@whedon` will try to compile the JOSS paper by looking for a `paper.md` file in the repository specified when the paper was submitted.

If he can't find the `paper.md` file he'll say as much in the review issue. If he can't compile the paper (i.e. there's some kind of Pandoc error), he'll try and report that error back in the thread too.

```eval_rst
.. note:: If you want to see what command ``@whedon`` is running when compiling the JOSS paper, take a look at the code `here <https://github.com/openjournals/whedon/blob/195e6d124d0fbd5346b87659e695325df9a18334/lib/whedon/processor.rb#L109-L132>`_.
```

Anyone can ask `@whedon` to compile the paper again (e.g. after a change has been made). To do this simply comment on the review thread as follows:

```text
@whedon generate pdf
```

### Finding reviewers

Sometimes submitting authors suggest people the think might be appropriate to review their submission. If you want the link to the current list of JOSS reviewers, type the following in the review thread:

```text
@whedon list reviewers
```

## Editorial commands

Most of `@whedon`'s functionality can only be used by the journal editors.

### Assigning an editor

Editors can either assign themselves or other editors as the editor of a submission as follows:

```text
@whedon assign @editorname as editor
```

### Adding and removing reviewers

Reviewers should be assigned by using the following commands:

```text
# Assign a GitHub user as the sole reviewer of this submission
@whedon assign @username as reviewer

# Add a GitHub user to the reviewers of this submission
@whedon add @username as reviewer

# Remove a GitHub user from the reviewers of this submission
@whedon remove @username as reviewer
```

```eval_rst
.. note:: The ``assign`` command clobbers all reviewer assignments. If you want to add an additional reviewer use the ``add`` command.
```

### Starting the review

Once the reviewer(s) and editor have been assigned in the `pre-review` issue, the editor starts the review with:

```text
@whedon start review magic-word=bananas
```

```eval_rst
.. important:: If a reviewer recants their commitment or is unresponsive, editors can remove them with the command ``@whedon remove @username as reviewer``. You can also add new reviewers in the ``REVIEW`` issue, but in this case, you need to manually add a review checklist for them by editing the issue body.
```

### Assigning the software archive

When a submission is accepted, we ask that the authors create an archive (on [Zenodo](https://zenodo.org/), [fig**share**](https://figshare.com/), or other) and post the archive DOI in the `REVIEW` issue. The editor should add the `accepted` label on the issue and ask `@whedon` to add the archive to the issue as follows:

```text
@whedon set <archive doi> as archive
```

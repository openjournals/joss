Review criteria
===============

## The JOSS paper

As outlined in the [submission guidelines provided to authors](submitting.html#what-should-my-paper-contain), the JOSS paper (the compiled PDF associated with this submission) should only include:

- A list of the authors of the software and their affiliations.
- A summary describing the high-level functionality and purpose of the software for a diverse, non-specialist audience.
- A clear statement of need that illustrates the purpose of the software.
- A description of how this software compares to other commonly-used packages in this research area.
- Mentions (if applicable) of any ongoing research projects using the software or recent scholarly publications enabled by it.
- A list of key references including a link to the software archive.

```eval_rst
.. important:: Note the paper *should not* include software documentation such as API (Application Programming Interface) functionality, as this should be outlined in the software documentation.
```

## Review items

```eval_rst
.. important:: Note, if you've not yet been involved in a JOSS review, you can see an example JOSS review checklist `here <review_checklist.html>`_.
```

### Software license

There should be an [OSI approved](https://opensource.org/licenses/alphabetical) license included in the repository. Common licenses such as those listed on [choosealicense.com](https://choosealicense.com) are preferred. Note there should be an actual license file present in the repository not just a reference to the license.

> **Acceptable:** A plain-text LICENSE or COPYING file with the contents of an OSI approved license<br />            
> **Not acceptable:** A phrase such as 'MIT license' in a README file

### Substantial scholarly effort

Reviewers should verify that the software represents substantial scholarly effort. As a rule of thumb, JOSS' minimum allowable contribution should represent **not less than** three months of work for an individual. Signals of effort may include: 

- Age of software (is this a well-established software project) / length of commit history.
- Number of commits.
- Number of authors.
- Lines of code (LOC): These statistics are usually reported by Whedon in the `pre-review` issue thread.
- Whether the software has already been cited in academic papers.
- Whether the software is sufficiently useful that it is _likely to be cited_ by other researchers working in this domain.

These guidelines are not meant to be strictly prescriptive. Recently released software may not have been around long enough to gather citations in academic literature. While some authors contribute openly and accrue a long and rich commit history before submitting, others may upload their software to GitHub shortly before submitting their JOSS paper.  Reviewers should rely on their expert understanding of their domain to judge whether the software is of broad interest (_likely to be cited by other researchers_) or more narrowly focused around the needs of an individual researcher or lab.

```eval_rst
.. note:: The decision on scholarly effort is ultimately one made by JOSS editors. Reviewers are asked to flag submissions of questionable scope during the review process so that the editor can bring this to the attention of the JOSS editorial team.
```

### Documentation

There should be sufficient documentation for you, the reviewer to understand the core functionality of the software under review. A high-level overview of this documentation should be included in a `README` file (or equivalent). There should be:

#### A statement of need

The authors should clearly state what problems the software is designed to solve and who the target audience is.

#### Installation instructions

There should be a clearly-stated list of dependencies. Ideally these should be handled with an automated package management solution.

> **Good:** A package management file such as a Gemfile or package.json or equivalent<br />
> **OK:** A list of dependencies to install<br />
> **Bad (not acceptable):** Reliance on other software not listed by the authors

#### Example usage

The authors should include examples of how to use the software (ideally to solve real-world analysis problems).

#### API documentation

Reviewers should check that the software API is documented to a suitable level.

> **Good:** All functions/methods are documented including example inputs and outputs<br />
> **OK:** Core API functionality is documented<br />
> **Bad (not acceptable):** API is undocumented

```eval_rst
.. note:: The decision on API documentation is left largely to the discretion of the reviewer and their experience of evaluating the software.
```

#### Community guidelines

There should be clear guidelines for third-parties wishing to:

- Contribute to the software
- Report issues or problems with the software
- Seek support

### Functionality

Reviewers are expected to install the software they are reviewing and to verify the core functionality of the software.

### Tests

Authors are strongly encouraged to include an automated test suite covering the core functionality of their software.

> **Good:** An automated test suite hooked up to an external service such as Travis-CI or similar<br />
> **OK:** Documented manual steps that can be followed to objectively check the expected functionality of the software (e.g., a sample input file to assert behavior)<br />
> **Bad (not acceptable):** No way for you, the reviewer, to objectively assess whether the software works

## Other considerations

### Authorship

As part of the review process, you are asked to check whether the submitting author has made a 'substantial contribution' to the submitted software (as determined by the commit history) and to check that 'the full list of paper authors seems appropriate and complete?'

As discussed in the [submission guidelines for authors](submitting.html#authorship), authorship is a complex topic with different practices in different communities.  Ultimately, the authors themselves are responsible for deciding which contributions are sufficient for co-authorship, although JOSS policy is that purely financial contributions are not considered sufficient. Your job as a reviewer is to check that the list of authors appears reasonable, and if it's not obviously complete/correct, to raise this as a question during the review.

### An important note about 'novel' software and citations of relevant work

Submissions that implement solutions already solved in other software packages are accepted into JOSS provided that they meet the criteria listed above and cite prior similar work. Reviewers should point out relevant published work which is not yet cited.

### What happens if the software I'm reviewing doesn't meet the JOSS criteria?

We ask that reviewers grade submissions in one of three categories: 1) Accept 2) Minor Revisions 3) Major Revisions. Unlike some journals we do not reject outright submissions requiring major revisions - we're more than happy to give the author as long as they need to make these modifications/improvements.

### What about submissions that rely upon proprietary languages/development environments?

As outlined in our author guidelines, submissions that rely upon a proprietary/closed source language or development environment are acceptable provided that they meet the other submission requirements and that you, the reviewer, are able to install the software & verify the functionality of the submission as required by our reviewer guidelines.

If an open source or free variant of the programming language exists, feel free to encourage the submitting author to consider making their software compatible with the open source/free variant.

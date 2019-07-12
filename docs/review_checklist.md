Review checklist
===============

JOSS reviews are checklist-driven. That is, there is a checklist for each JOSS reviewer to work through when completing their review. A JOSS review is generally considered incomplete until the reviewer has checked off all of their checkboxes.

Below is an example of the review checklist for the [Yellowbrick JOSS submission](https://github.com/openjournals/joss-reviews/issues/1075).

```eval_rst
.. important:: Note this section of our documentation only describes the JOSS review checklist. Authors and reviewers should consult the `review criteria <review_criteria.html>`_ to better understand how these checklist items should be interpreted.
```
### Conflict of interest

- As the reviewer I confirm that I have read the [JOSS conflict of interest policy](reviewer_guidelines.html#joss-conflict-of-interest-policy) and that there are no conflicts of interest for me to review this work.

### Code of Conduct

- I confirm that I read and will adhere to the [JOSS code of conduct](https://joss.theoj.org/about#code_of_conduct).

### General checks

- **Repository:** Is the source code for this software available at the <a target="_blank" href="https://github.com/DistrictDataLabs/yellowbrick">repository url</a>?
- **License:** Does the repository contain a plain-text LICENSE file with the contents of an [OSI approved](https://opensource.org/licenses/alphabetical) software license?
- **Version:** Does the release version given match the GitHub release (v0.8)?
- **Authorship:** Has the submitting author made major contributions to the software? Does the full list of paper authors seem appropriate and complete?

### Functionality

- **Installation:** Does installation proceed as outlined in the documentation?
- **Functionality:** Have the functional claims of the software been confirmed?
- **Performance:** If there are any performance claims of the software, have they been confirmed? (If there are no claims, please check off this item.)

### Documentation

- **A statement of need:** Do the authors clearly state what problems the software is designed to solve and who the target audience is?
- **Installation instructions:** Is there a clearly-stated list of dependencies? Ideally these should be handled with an automated package management solution.
- **Example usage:** Do the authors include examples of how to use the software (ideally to solve real-world analysis problems).
- **Functionality documentation:** Is the core functionality of the software documented to a satisfactory level (e.g., API method documentation)?
- **Automated tests:** Are there automated tests or manual steps described so that the function of the software can be verified?
- **Community guidelines:** Are there clear guidelines for third parties wishing to 1) Contribute to the software 2) Report issues or problems with the software 3) Seek support

### Software paper

- **Authors:** Does the `paper.md` file include a list of authors with their affiliations?
- **A statement of need:** Do the authors clearly state what problems the software is designed to solve and who the target audience is?
- **References:** Do all archival references that should have a DOI list one (e.g., papers, datasets, software)?

# EiC Guide

This section of the documentation is for the JOSS Editor-in-Chief (EiC) team, i.e., the Editor-in-Chief and the Associate Editors-in-Chief (AEiCs). It covers administrative tasks that require EiC/AEiC access to the JOSS site and to Open Journals' GitHub organization and Slack.

## Off-boarding an editor

When an editor steps down from the editorial team, the EiC (or an AEiC with admin access) should complete the following steps.

**Before off-boarding**

- Check whether they are still editing any submissions (their dashboard at `https://joss.theoj.org/dashboard/<theirgithubusername>` lists their current papers). Either wait for them to wrap these up, or agree with them which papers need to be reassigned to another editor.

**Off-boarding steps**

1. Mark the editor as "emeritus" on the JOSS site: visit `https://joss.theoj.org/editors/<editor-id>/edit` (find them via the [editors list](https://joss.theoj.org/editors)), change the **Kind** to `emeritus`, and save. Emeritus editors no longer appear in the list of active editors.
2. Remove them from the [joss-editors GitHub team](https://github.com/orgs/openjournals/teams/joss-editors).
3. Remove them from the `#joss` channel on Slack.
4. Remove them from the editors Google Group.

## Editing paper metadata

Sometimes a paper's metadata needs correcting after acceptance — for example, encoding issues in the title, incorrect or missing tags or languages, or a malformed citation string. AEiCs can fix these directly from the paper's admin page (`https://joss.theoj.org/papers/<DOI>/admin`) using the **Edit paper metadata** panel.

The form has four fields, all optional — any field left blank keeps its current value:

- **Title**: The paper's title, as displayed on the site.
- **Tags** (comma-separated): Note that tags duplicating a displayed language are automatically hidden from the Tags section on the paper page.
- **Languages** (comma-separated): Note that some languages are never displayed on the paper page (e.g., Shell, TeX, Makefile, HTML, CSS, CMake, Dockerfile, Batchfile).
- **Citation string**: The formatted citation shown for the paper.

```{warning}
Directly editing paper metadata bypasses the normal submission processes, and changes take effect immediately on the live site. Only use this to correct data errors. Note also that this only updates the metadata stored in the JOSS database (i.e., what is displayed on the JOSS site) — it does not recompile the paper PDF or update the Crossref deposit.
```

# EiC Guide

This section of the documentation is for the JOSS Editor-in-Chief (EiC) team, i.e., the Editor-in-Chief and the Associate Editors-in-Chief (AEiCs). It covers administrative tasks that require EiC/AEiC access to the JOSS site and to Open Journals' GitHub organization and Slack.

## Onboarding a new editor

Once a candidate has had their onboarding call (see [Editor Onboarding](editor_onboarding)) and has agreed to join the team, they are set up using the **Onboarding** tab of the AEiC dashboard (`https://joss.theoj.org/onboardings`).

**1. Send an onboarding invitation**

Enter the new editor's email address (and optionally their name) and click **Invite**. This emails them a link to a form where they complete their editor profile. Until they complete it, the invitation is listed under **Editor invitations**, where you can **Re-invite** (re-send the email) or **Delete** it.

To use the link, the new editor must be logged in to the JOSS site with an account whose email matches the one the invitation was sent to. If their ORCID email is different (or private), they can change the email on their account under **My Profile** (`https://joss.theoj.org/profile`).

**2. Wait for them to complete their profile**

Once the new editor submits the form (name, email, GitHub username, tracks, etc.), they are added as a *pending* editor and appear in the **Pending editors** table with the status "Information registered. Ready to be invited to GitHub team".

**3. Invite them to the GitHub editors team**

Click **Send invitation to join GitHub team**. This sends them an invitation to join the Open Journals GitHub organization and the joss-editors team. The status changes to "Invitation to join organization sent. Pending acceptance." and then to "Joined GitHub organization and editors team!" once they accept. If needed, you can re-send the invitation from the same table.

**4. Approve them**

Click **Approve**. This makes them an active (topic) editor and removes their onboarding invitation.

**5. Manual steps**

The following are not handled by the JOSS site and need to be done manually:

- Invite them to the Open Journals Slack, and add them to the `#joss` channel.
- Assign their onboarding buddy: edit the editor (`https://joss.theoj.org/editors/<editor-id>/edit`) and select their buddy in the **Buddy** field.
- Check their capacity: new editors get a **Max number of assignments** of 4 by default. During their trial period this should usually be lowered to 2 (on the same edit page), and raised once they are up to speed.
- Add them to the invitation for the optional monthly editor telecon

## Off-boarding an editor

When an editor steps down from the editorial team, the EiC (or an AEiC with admin access) should complete the following steps.

**Before off-boarding**

- Check whether they are still editing any submissions (their dashboard at `https://joss.theoj.org/dashboard/<theirgithubusername>` lists their current papers). Either wait for them to wrap these up, or agree with them which papers need to be reassigned to another editor.

**Off-boarding steps**

1. Mark the editor as "emeritus" on the JOSS site: visit `https://joss.theoj.org/editors/<editor-id>/edit` (find them via the [editors list](https://joss.theoj.org/editors)), change the **Kind** to `emeritus`, and save. Emeritus editors no longer appear in the list of active editors.
2. Remove them from the [joss-editors GitHub team](https://github.com/orgs/openjournals/teams/joss-editors).
3. Remove them from the `#joss` channel on Slack.
4. Remove them from the invitation for the optional monthly editor telecon

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

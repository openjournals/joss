# JOSS Editor workflow

1. An author submits a paper. They can select or not select an editor.

2. If you are selected as an editor you get @’d in the pre-review issue. 
This doesn’t mean that you’re the editor, just that you’ve been suggested by the author.

3. If a paper is submitted without a recommended editor, it will show up in the weekly 
digest email under the category ‘Papers currently without an editor.’ Please review this 
weekly email and volunteer to edit papers that look to be in your domain. If you choose 
to be an editor in the issue thread type the command `@whedon assign @yourhandle as editor`

4. Once you are the editor, find the link to the code repository in the Pre-review issue

5. The editor looks at the software submitted and checks to see if
    * There’s a general description of the software
    * The software is within scope as research software
    * It has an OSI approved license

6. The editor responds to the author saying that things look in line (or not) and will search for reviewer

7. The editor finds >= 1 reviewers
    * use the list of reviewers: type the command `@whedon list reviewers` 
    or look at list of reviewers in a Google [spreadsheet](https://docs.google.com/spreadsheets/d/1PAPRJ63yq9aPC1COLjaQp8mHmEq3rZUzwUYxTulyu78/edit?usp=sharing) 
    If people are in the review list, the editor can @-mention them on the issue to see if they will review,
    e.g. @person1 @person2 can you review?
    * or solicit reviewers outside the list. Send an email to people describing what JOSS is 
    and asking if they would be interested in reviewing.

8. Editor tells whedon to assign the reviewer to the paper: use `@whedon assign @reviewer as reviewer`

9. Create the actual review issue: `@whedon start review magic-word=bananas`
    * An issue is created with the review checklist, e.g. https://github.com/openjournals/joss-reviews/issues/307 
    
10. Close the pre-review issue.

11. Review: The reviewer reviews the paper and has a conversation with the author. The editor lurks 
on this conversation and comes in if needed for questions (or CoC issues).
The reviewer potentially asks for changes and the author makes changes. Everyone agrees it’s ready.

12. Editor pings the EiC (@arfon) to get the paper published (mention @arfon in the issue)

13. Celebrate publication! Tweet! Thank reviewers! Say thank you on issue.

*Extras:*
* If you need to change the reviewer: (@whedon assign @reviewer as reviewer) 
This can be done in the PRE REVIEW or the REVIEW issue.

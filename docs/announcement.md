# JOSS

It's time to take the wrapping off a new side-project I've been working on for past few months: [The Journal of Open Source Software](http://joss.theoj.org).

The Journal of Open Source Software (JOSS for short) is a new take on an idea that's been gaining some traction over the last few years, that is, to publish papers _about_ software.

On the face of it, writing papers about software is a weird thing to do, especially if there's a public software repository, documentation and perhaps even a website for users of the software. But writing a papers about software is currently the only sure way for authors to gaining career credit as it creates a citable entity<sup>1</sup> (a paper) that can be referenced by other authors.

If an author of research software is interested in writing a paper describing their work then there are a number of journals such as [Journal of Open Research Software](http://openresearchsoftware.metajnl.com/) and [SoftwareX](http://www.journals.elsevier.com/softwarex/) dedicated to reviewing such papers. In addition, professional societies such as the [American Astronomical Society](https://aas.org/) have explicitly stated that software papers [are welcome in their journals](http://journals.aas.org/policy/software.html). In most cases though, submissions to these journals are full-length papers that conflate two things: 1) A description of the software and 2) Some novel research results generated using the software.

## The big problem with software papers

The problem with software papers though is exactly what I wrote earlier: _they're the only sure way for authors to gaining career credit<sup>2</sup>_. Or, put differently, they're a necessary hack for a crappy metrics system. Buckheit & Donoho nailed it in their article about [reproducible research](http://statweb.stanford.edu/~wavelab/Wavelab_850/wavelab.pdf) when they said:

> An article about computational science in a scientific publication is not the scholarship itself, it is merely advertising of the scholarship. The actual scholarship is the complete software development environment and the complete set of instructions which generated the figures.

As academics, it's important for us to be able to measuring the impact of our work, but the tools & metrics we have available to us right now are woefully lacking when it comes to tracking research output that doesn't look like a paper. A [2009 survey of more than 2000 researchers](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=5069155) found that > 90% of them consider software important or very important to their work but even if you've followed this [GitHub guide](https://guides.github.com/activities/citable-code/) for archiving a GitHub repository with Zenodo (and acquired a DOI in the process), citations to your work [probably aren't being counted](http://www.carlboettiger.info/2013/06/03/DOI-citable.html) by the people that matter.

## Embracing the hack

In the long term we should moving away from closed/proprietary solutions such as Scopus and Web of Science which primarily track papers and their citations and moving to tools that can track things without DOIs such as http://depsy.org. That's the long-term fix though and not the one that helps the [researchers software engineers](http://www.rse.ac.uk/who.html) of today.

If software papers are the current best solution for gaining career credit for software then shouldn't we be making it as easy as possible to create a software paper? Building high quality software is already a lot of work, what if we could make the process of writing a software paper take less than an hour?

## The Journal of Open Source Software

The Journal of Open Source Software is a developer friendly journal for research software packages. It's designed to make it as easy as possible to create a software paper for your work. If a piece of software is already well documented then paper preparation (and submission) should take no more than an hour.

The JOSS 'paper' is deliberately extremely short and is only allowed to include:

- A short abstract describing the high-level functionality of the software
- A list of the authors of the software (together with their affiliations)
- A list of key references including a link to the software archive

Paper are not allowed to include other things such as descriptions of API functionality as this should be included in the software documentation. You can see an example of a paper [here](https://github.com/arfon/fidgit/blob/master/paper/paper.pdf).

## Oh cool. You're going to publish crappy papers!

Not at all. Remember software papers are just advertising and JOSS 'papers' are essentially just abstracts that point to a software repository. The primary purpose of a JOSS paper is to enable citation credit to be given to authors of research software.

We're also not going to just let any old software through: JOSS has a [rigorous peer review process](http://joss.theoj.org/about#reviewer_guidelines) and a first-class [editorial board](http://joss.theoj.org/about#editorial_board) each highly experienced at building (and reviewing) high-quality research software.

## So what's the review for?

JOSS reviews are designed to improve the software being submitted. Our review process is based upon the tried-and-tested approach taken by the [rOpenSci collaboration](https://github.com/ropensci) and happens [on GitHub](https://github.com/openjournals/joss-reviews). Reviews of software papers rarely improve the codebase<sup>3</sup> _but they do improve documentation_ - a critical part of making usable software so our review process is about making sure the pieces are in place for open, (re)usable, well-documented code.

## To the future!

Let me be clear, I think software papers are a nasty hack on a broken credit system for academia and that the ideal solution is to move away from papers as the only creditable research product.

None of this helps the students/postdocs/early career researchers of _today_ who are having to make very hard decisions about whether to spend time improving the software they've written for their research (and others in their community) or whether they should crank out a few papers to make them look like a 'productive' researcher.

JOSS exists because we believe that after you've done the hard work of writing great software, it shouldn't take weeks and months to write a paper about your work.

## I'm in, how can I help?

Great! There are two main ways you can help 1) Cite JOSS software papers when they exist for a piece of software you've used 2) Perhaps [volunteer to review some stuff](https://github.com/openjournals/joss/issues/new?title=I%27d%20like%20to%20review%20for%20JOSS) for us? And of course, you might like to submit something - take a look at our [author guidelines](http://joss.theoj.org/about#author_guidelines) and let us know what you think.

## Thanks

Finally, I'd like to say thanks to all the people who've helped shape JOSS into its current form. Thanks to Karthik Ram, Kevin M. Moerman and all the people who've agreed to be on the [editorial board](http://joss.theoj.org/about#editorial_board).

<sup>1.</sup> You can of course cite other things, they just don't necessarily count towards your h-index.  
<sup>2.</sup> This assumes of course that authors remember to cite your software paper.  
<sup>3.</sup> Citation needed. Ask your friends/colleagues who have written a software paper whether they think the reviewer even _looked_ at the code.



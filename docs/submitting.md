Submitting a paper to JOSS
==========================

If you've already licensed your code and have good documentation then we expect that it should take less than an hour to prepare and submit your paper to JOSS.

## Typical paper submission flow

Before you submit we need you to:

- Make software available in an open repository (GitHub, Bitbucket etc.) and include an [OSI approved open source license](https://opensource.org/licenses)
- Make sure that the software complies with the [JOSS review criteria](review_criteria.html).
- Author a short Markdown paper `paper.md` with a title, summary, author names, affiliations, and key references. See an example [here](https://github.com/arfon/fidgit/tree/master/paper).
- (Optional) create a metadata file and include it in your repository describing your software. [This script](https://gist.github.com/arfon/478b2ed49e11f984d6fb) automates the generation of this metadata.


## What should my paper contain?

JOSS welcomes submissions from broadly diverse research areas. For this reason, we request that authors include in the paper some sentences that would explain the software functionality and domain of use to a non-specialist reader. Your submission should probably be somewhere between 250-1000 words.

In addition, your paper should include:

- A list of the authors of the software and their affiliations
- A summary describing the high-level functionality and purpose of the software for a diverse, *non-specialist audience*
- A clear statement of need that illustrates the purpose of the software
- A list of key references including a link to the software archive
- Mentions (if applicable) of any ongoing research projects using the software or recent scholarly publications enabled by it

As this short list shows, JOSS papers are only permitted to contain a limited set of metadata (see header below), Statement of Need, Summary, and Reference sections. You can see an example accepted paper [here](https://raw.githubusercontent.com/adrn/gala/f6bb2532afeed3c0b0feea3037bf71a3f42b2a12/paper/paper.md). Given this paper format, a "full length" paper is not permitted, e.g., software documentation such as API (Application Programming Interface) functionality should not be in the paper and instead should be outlined in the software documentation.

```eval_rst
.. important:: You paper will be reviewed by one or more reviewers in a public GitHub issue. Take a look at the `review criteria <review_criteria.html>`_ to better understand how your submission will be reviewed.
```

## Example paper and bibliography

This example `paper.md` is adapted from _Gala: A Python package for galactic dynamics_ by Adrian M. Price-Whelan [http://doi.org/10.21105/joss.00388](http://doi.org/10.21105/joss.00388):

```
---
title: 'Gala: A Python package for galactic dynamics'
tags:
  - Python
  - astronomy
  - dynamics
  - galactic dynamics
  - milky way
authors:
  - name: Adrian M. Price-Whelan
    orcid: 0000-0003-0872-7098
    affiliation: "1, 2" # (Multiple affiliations must be quoted)
  - name: Author 2
    orcid: 0000-0000-0000-0000
    affiliation: 2
affiliations:
 - name: Lyman Spitzer, Jr. Fellow, Princeton University
   index: 1
 - name: Institution 2
   index: 2
date: 13 August 2017
bibliography: paper.bib
---

# Summary

The forces on stars, galaxies, and dark matter under external gravitational
fields lead to the dynamical evolution of structures in the universe. The orbits
of these bodies are therefore key to understanding the formation, history, and
future state of galaxies. The field of "galactic dynamics," which aims to model
the gravitating components of galaxies to study their structure and evolution,
is now well-established, commonly taught, and frequently used in astronomy.
Aside from toy problems and demonstrations, the majority of problems require
efficient numerical tools, many of which require the same base code (e.g., for
performing numerical orbit integration).

``Gala`` is an Astropy-affiliated Python package for galactic dynamics. Python
enables wrapping low-level languages (e.g., C) for speed without losing
flexibility or ease-of-use in the user-interface. The API for ``Gala`` was
designed to provide a class-based and user-friendly interface to fast (C or
Cython-optimized) implementations of common operations such as gravitational
potential and force evaluation, orbit integration, dynamical transformations,
and chaos indicators for nonlinear dynamics. ``Gala`` also relies heavily on and
interfaces well with the implementations of physical units and astronomical
coordinate systems in the ``Astropy`` package [@astropy] (``astropy.units`` and
``astropy.coordinates``).

``Gala`` was designed to be used by both astronomical researchers and by
students in courses on gravitational dynamics or astronomy. It has already been
used in a number of scientific publications [@Pearson:2017] and has also been
used in graduate courses on Galactic dynamics to, e.g., provide interactive
visualizations of textbook material [@Binney:2008]. The combination of speed,
design, and support for Astropy functionality in ``Gala`` will enable exciting
scientific explorations of forthcoming data releases from the *Gaia* mission
[@gaia] by students and experts alike. The source code for ``Gala`` has been
archived to Zenodo with the linked DOI: [@zenodo]

# Mathematics

Single dollars ($) are required for inline mathematics e.g. $f(x) = e^{\pi/x}$

Double dollars make self-standing equations:

$$\Theta(x) = \left\{\begin{array}{l}
0\textrm{ if } x < 0\cr
1\textrm{ else}
\end{array}\right.$$


# Citations

Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

# Figures

Figures can be included like this: ![Example figure.](figure.png)

# Acknowledgements

We acknowledge contributions from Brigitta Sipocz, Syrtis Major, and Semyeong
Oh, and support from Kathryn Johnston during the genesis of this project.

# References
```

Example `paper.bib` file:

```
@article{Pearson:2017,
  	Adsnote = {Provided by the SAO/NASA Astrophysics Data System},
  	Adsurl = {http://adsabs.harvard.edu/abs/2017arXiv170304627P},
  	Archiveprefix = {arXiv},
  	Author = {{Pearson}, S. and {Price-Whelan}, A.~M. and {Johnston}, K.~V.},
  	Eprint = {1703.04627},
  	Journal = {ArXiv e-prints},
  	Keywords = {Astrophysics - Astrophysics of Galaxies},
  	Month = mar,
  	Title = {{Gaps in Globular Cluster Streams: Pal 5 and the Galactic Bar}},
  	Year = 2017
}

@book{Binney:2008,
  	Adsnote = {Provided by the SAO/NASA Astrophysics Data System},
  	Adsurl = {http://adsabs.harvard.edu/abs/2008gady.book.....B},
  	Author = {{Binney}, J. and {Tremaine}, S.},
  	Booktitle = {Galactic Dynamics: Second Edition, by James Binney and Scott Tremaine.~ISBN 978-0-691-13026-2 (HB).~Published by Princeton University Press, Princeton, NJ USA, 2008.},
  	Publisher = {Princeton University Press},
  	Title = {{Galactic Dynamics: Second Edition}},
  	Year = 2008
}

@article{zenodo,
  	Abstractnote = {Gala is a Python package for Galactic astronomy and gravitational dynamics. The bulk of the package centers around implementations of gravitational potentials, numerical integration, and nonlinear dynamics.},
  	Author = {Adrian Price-Whelan and Brigitta Sipocz and Syrtis Major and Semyeong Oh},
  	Date-Modified = {2017-08-13 14:14:18 +0000},
  	Doi = {10.5281/zenodo.833339},
  	Month = {Jul},
  	Publisher = {Zenodo},
  	Title = {adrn/gala: v0.2.1},
  	Year = {2017},
  	Bdsk-Url-1 = {http://dx.doi.org/10.5281/zenodo.833339}
}

@article{gaia,
    author = {{Gaia Collaboration}},
    title = "{The Gaia mission}",
    journal = {\aap},
    archivePrefix = "arXiv",
    eprint = {1609.04153},
    primaryClass = "astro-ph.IM",
    keywords = {space vehicles: instruments, Galaxy: structure, astrometry, parallaxes, proper motions, telescopes},
    year = 2016,
    month = nov,
    volume = 595,
    doi = {10.1051/0004-6361/201629272},
    adsurl = {http://adsabs.harvard.edu/abs/2016A%26A...595A...1G},
}

@article{astropy,
    author = {{Astropy Collaboration}},
    title = "{Astropy: A community Python package for astronomy}",
    journal = {\aap},
    archivePrefix = "arXiv",
    eprint = {1307.6212},
    primaryClass = "astro-ph.IM",
    keywords = {methods: data analysis, methods: miscellaneous, virtual observatory tools},
    year = 2013,
    month = oct,
    volume = 558,
    doi = {10.1051/0004-6361/201322068},
    adsurl = {http://adsabs.harvard.edu/abs/2013A%26A...558A..33A}
}
```

Note that the paper ends with a References heading, and the references are built automatically from the content in the .bib file when they are mentioned in the paper body.

## Submitting your paper

Submission then is as simple as:

- Filling in the [short submission form](http://joss.theoj.org/papers/new)
- Waiting for reviewers to be assigned over in the JOSS reviews repository: https://github.com/openjournals/joss-reviews

## Submission requirements

- The software should be open source as per the [OSI definition](https://opensource.org/osd)
- The software should have an **obvious** research application
- You should be a major contributor to the software you are submitting
- The software should be a significant contribution to the available open source software that either enables some new research challenges to be addressed or makes addressing research challenges significantly better (e.g., faster, easier, simpler)
- The software should be feature complete (no half-baked solutions) and
  designed for maintainable extension (not one-off modifications).
  Minor ‘utility’ packages, including ‘thin’ API clients, are not
  acceptable.

In addition, the software associated with your submission must:

- Be stored in a repository that can be cloned without registration
- Be stored in a repository that is browsable online without registration
- Have an issue tracker that is readable without registration
- Permit individuals to create issues/file tickets against your repository

JOSS publishes articles about research software. This definition includes software that: solves complex modeling problems in a scientific context (physics, mathematics, biology, medicine, social science, neuroscience, engineering); supports the functioning of research instruments or the execution of research experiments; extracts knowledge from large data sets; offers a mathematical library, or similar.

## Submission fees

There are no fees for submitting or publishing in JOSS. You can read more about our cost and sustainability model [here](http://joss.theoj.org/about#costs).

## Authorship

Purely financial (such as being named on an award) and organizational (such as general supervision of a research group) contributions are not considered sufficient for co-authorship of JOSS submissions, but active project direction and other forms of non-code contributions are. The authors themselves assume responsibility for deciding who should be credited with co-authorship, and co-authors must always agree to be listed. In addition, co-authors agree to be accountable for all aspects of the work.

## Submissions using proprietary languages/dev environments

We strongly prefer software that doesn't rely upon proprietary (paid for) development environments/programming languages. However, provided _your submission_ meets our submission requirements (including having a valid open source license) then we will consider your submission for review. Should your submission be accepted for review, we may ask you, the submitting author, to help us find reviewers who already have the required development environment installed.

## The review process

After submission:

- One or more JOSS reviewers are assigned and the review is carried out in the [reviews repository](https://github.com/openjournals/joss-reviews)
- Authors respond to reviewer-raised issues (if any are raised) on the submitted repository's issue tracker. Reviewer contributions, like any other contributions, should be acknowledged in the repository
- Upon successful completion of the review, deposit a copy of your (updated) repository with a data-archiving service such as [Zenodo](https://zenodo.org/) or [figshare](https://figshare.com/), issue a DOI for the archive, and update the review issue thread with your DOI
- After assignment of a DOI, your paper metadata is deposited in CrossRef and listed on the JOSS website
- And that's it

If you want to learn more about what the review process looks like in detail, take a look at the [reviewer guidelines](reviewer_guidelines.html).

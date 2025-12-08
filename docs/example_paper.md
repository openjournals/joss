# Example Paper

This example `paper.md` is adapted from _Gala: A Python package for galactic dynamics_ by Adrian M. Price-Whelan [http://doi.org/10.21105/joss.00388](http://doi.org/10.21105/joss.00388).

For a complete description of available options to describe author names [see here](author-names).

```markdown
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
    orcid: 0000-0000-0000-0000
    equal-contrib: true
    affiliation: "1, 2" # (Multiple affiliations must be quoted)
  - name: Author Without ORCID
    equal-contrib: true # (This is how you can denote equal contributions between multiple authors)
    affiliation: 2
  - name: Author with no affiliation
    corresponding: true # (This is how to denote the corresponding author)
    affiliation: 3
  - given-names: Ludwig
    dropping-particle: van
    surname: Beethoven
    affiliation: 3
affiliations:
 - name: Lyman Spitzer, Jr. Fellow, Princeton University, United States
   index: 1
   ror: 00hx57361
 - name: Institution Name, Country
   index: 2
 - name: Independent Researcher, Country
   index: 3
date: 13 August 2017
bibliography: paper.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
aas-journal: Astrophysical Journal <- The name of the AAS journal.
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

# Statement of need

`Gala` is an Astropy-affiliated Python package for galactic dynamics. Python
enables wrapping low-level languages (e.g., C) for speed without losing
flexibility or ease-of-use in the user-interface. The API for `Gala` was
designed to provide a class-based and user-friendly interface to fast (C or
Cython-optimized) implementations of common operations such as gravitational
potential and force evaluation, orbit integration, dynamical transformations,
and chaos indicators for nonlinear dynamics. `Gala` also relies heavily on and
interfaces well with the implementations of physical units and astronomical
coordinate systems in the `Astropy` package [@astropy] (`astropy.units` and
`astropy.coordinates`).

`Gala` was designed to be used by both astronomical researchers and by
students in courses on gravitational dynamics or astronomy. It has already been
used in a number of scientific publications [@Pearson:2017] and has also been
used in graduate courses on Galactic dynamics to, e.g., provide interactive
visualizations of textbook material [@Binney:2008]. The combination of speed,
design, and support for Astropy functionality in `Gala` will enable exciting
scientific explorations of forthcoming data releases from the *Gaia* mission
[@gaia] by students and experts alike.

# Software design

`Gala`'s design philosophy is based on three core principles: (1) to provide a user-friendly, modular, object-oriented API, (2) to use community tools and standards (e.g., Astropy for coordinates and units handling), and (3) to use low-level code (C/C++/Cython) for performance while keeping the user interface in Python. Within each of the main subpackages in `gala` (`gala.potential`, `gala.dynamics`, `gala.integrate`, etc.), we try to maintain a consistent API for classes and functions. For example, all potential classes share a common base class and implement methods for computing the potential, forces, density, and other derived quantities at given positions. This also works for compositions of potentials (i.e., multi-component potential models), which share the potential base class but also act as a dictionary-like container for different potential components. As another example, all integrators implement a common interface for numerically integrating orbits. The integrators and core potential functions are all implemented in C without support for units, but the Python layer handles unit conversions and prepares data to dispatch to the C layer appropriately.Within the coordinates subpackage, we extend Astropy's coordinate classes to add more specialized coordinate frames and transformations that are relevant for Galactic dynamics and Milky Way research.

# Research impact statement

`Gala` has demonstrated substantial research impact since its initial release. The package
has been used in over 50 peer-reviewed publications spanning diverse topics in galactic
dynamics, including studies of tidal streams [@Pearson:2017], dark matter substructure
detection, and the dynamics of stellar systems. External adoption includes integration
into the Astropy ecosystem as an affiliated package and incorporation into graduate-level
curricula at multiple institutions [@Binney:2008].

The package's impact extends beyond direct citations through enabling new research
methodologies. `Gala`'s fast orbit integration and coordinate transformation capabilities
have become critical infrastructure for analyzing data from the *Gaia* space mission [@gaia],
which has delivered positions and velocities for over 1 billion stars. The package has been
adopted by the broader community for diverse applications, from analyzing stellar streams
and dark matter distribution to modeling binary stellar evolution in galactic contexts
[@Hunt:2025]. The package has been downloaded over 100,000 times from PyPI and conda-forge,
with active usage indicated by sustained issue reporting and feature requests from researchers
across multiple institutions and countries. This broad adoption validates `Gala`'s role as
essential infrastructure for the galactic dynamics research community.

# Mathematics

Single dollars ($) are required for inline mathematics e.g. $f(x) = e^{\pi/x}$

Double dollars make self-standing equations:

$$\Theta(x) = \left\{\begin{array}{l}
0\textrm{ if } x < 0\cr
1\textrm{ else}
\end{array}\right.$$

You can also use plain \LaTeX for equations
\begin{equation}\label{eq:fourier}
\hat f(\omega) = \int_{-\infty}^{\infty} f(x) e^{i\omega x} dx
\end{equation}
and refer to \autoref{eq:fourier} from text.

# Citations

Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

If you want to cite a software repository URL (e.g. something on GitHub without a preferred
citation) then you can do it with the example BibTeX entry below for @fidgit.

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

# Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example}](figure.png)
and referenced from text using \autoref{fig:example}.

Figure sizes can be customized by adding an optional second parameter:
![Caption for example figure.](figure.png){ width=20% }

# AI usage disclosure

No generative AI tools were used in the development of this software, the writing
of this manuscript, or the preparation of supporting materials.

# Acknowledgements

We acknowledge contributions from Brigitta Sipocz, Syrtis Major, and Semyeong
Oh, and support from Kathryn Johnston during the genesis of this project.

# References

```

Example `paper.bib` file:

```
@article{Pearson:2017,
  	url = {http://adsabs.harvard.edu/abs/2017arXiv170304627P},
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
  	url = {http://adsabs.harvard.edu/abs/2008gady.book.....B},
  	Author = {{Binney}, J. and {Tremaine}, S.},
  	Booktitle = {Galactic Dynamics: Second Edition, by James Binney and Scott Tremaine.~ISBN 978-0-691-13026-2 (HB).~Published by Princeton University Press, Princeton, NJ USA, 2008.},
  	Publisher = {Princeton University Press},
  	Title = {{Galactic Dynamics: Second Edition}},
  	Year = 2008
}

@article{gaia,
    author = {{Gaia Collaboration}},
    title = "{The Gaia mission}",
    journal = {Astronomy and Astrophysics},
    archivePrefix = "arXiv",
    eprint = {1609.04153},
    primaryClass = "astro-ph.IM",
    keywords = {space vehicles: instruments, Galaxy: structure, astrometry, parallaxes, proper motions, telescopes},
    year = 2016,
    month = nov,
    volume = 595,
    doi = {10.1051/0004-6361/201629272},
    url = {http://adsabs.harvard.edu/abs/2016A%26A...595A...1G},
}

@article{astropy,
    author = {{Astropy Collaboration}},
    title = "{Astropy: A community Python package for astronomy}",
    journal = {Astronomy and Astrophysics},
    archivePrefix = "arXiv",
    eprint = {1307.6212},
    primaryClass = "astro-ph.IM",
    keywords = {methods: data analysis, methods: miscellaneous, virtual observatory tools},
    year = 2013,
    month = oct,
    volume = 558,
    doi = {10.1051/0004-6361/201322068},
    url = {http://adsabs.harvard.edu/abs/2013A%26A...558A..33A}
}

@article{Hunt:2025,
  author = {{Hunt}, Jason A.~S. and {Vasiliev}, Eugene},
  title = {Milky Way dynamics in light of Gaia},
  journal = {New Astronomy Reviews},
  year = 2025,
  volume = 98,
  doi = {10.1016/j.newar.2024.101721},
  url = {https://www.sciencedirect.com/science/article/pii/S1387647324000289}
}

@misc{fidgit,
  author = {A. M. Smith and K. Thaney and M. Hahnel},
  title = {Fidgit: An ungodly union of GitHub and Figshare},
  year = {2020},
  publisher = {GitHub},
  journal = {GitHub repository},
  url = {https://github.com/arfon/fidgit}
}
```

Note that the paper begins by a metadata section (the enclosing --- lines are mandatory) and ends with a References heading, and the references are built automatically from the content in the `.bib` file. You should enter in-text citations in the paper body following correct [Markdown citation syntax](https://pandoc.org/MANUAL.html#extension-citations).  Also note that the references include full names of venues, e.g., journals and conferences, not abbreviations only understood in the context of a specific discipline.

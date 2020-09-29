Installing the JOSS application
===============================

Any open journal (JOSS, JOSE, etc.) can be considered in three parts:

1. The website
2. The Whedon gem
3. A thin API wrapper around the Whedon gem to interface with GitHub

For JOSS, these correspond to the
`JOSS <https://github.com/openjournals/joss>`_,
`Whedon <https://github.com/openjournals/whedon>`_, and
`Whedon-API <https://github.com/openjournals/whedon-api>`_ code bases.

Setting up a local development environment
------------------------------------------

All open journals are coded in Ruby,
with the website and Whedon-API developed as
`Ruby on Rails <https://rubyonrails.org/inst>`_ applications.

If you'd like to develop these locally,
you'll need a working Ruby on Rails development environment.
For more information, please see
`this official guide <https://guides.rubyonrails.org/getting_started.html#creating-a-new-rails-project-installing-rails>`_.

Deploying your JOSS application
-------------------------------

To deploy JOSS, you'll need a `Heroku account <https://signup.heroku.com/>`_.
We also recommend you gather the following information
before deploying your application to Heroku:

1. A `public ORCID API <https://members.orcid.org/api/about-public-api>`_ key
1. A GitHub `Personal Access Token <https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token>`_ for the automated account that users will interact with (e.g., whedon, roboneuro)
1. An email address registered on a domain you control (i.e., not gmail or a related service)

For now, please take a look at the [JOSS codebase](https://github.com/openjournals/joss).

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
1. A GitHub `Personal Access Token <https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token>`_ for the automated account that users will interact with (e.g., Whedon, RoboNeuro)
1. An email address registered on a domain you control (i.e., not gmail or a related service)

.. warning::
    Do not put these secrets directly into your code base!
    It is important that these keys are not under version control.

    There are different ways to make sure your application has access to these keys,
    depending on whether your code is being developed locally or on Heroku.
    Locally, you can store these locally in a .env file.
    The .gitignore in JOSS is already set to ignore this file type.

    On Heroku, they will be config variables that you can set either with the Heroku CLI or directly on your application's dashboard.
    See `this guide from Heroku <https://devcenter.heroku.com/articles/config-vars#managing-config-vars>`_ for more information.

Assuming you `have forked the JOSS GitHub repository <https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo>`_
to your account, you can `configure Heroku as a git remote <https://devcenter.heroku.com/articles/git#prerequisites-install-git-and-the-heroku-cli>`_ for your code.
This makes it easy to keep your Heroku deployment in sync with your local development copy.

On the JOSS Heroku deployment, you'll need to provision several `add-ons <https://elements.heroku.com/addons>`_.
Specifically, you'll need an:

1. `Elasticsearch add-on <https://elements.heroku.com/addons/bonsai>`_,
1. `Postgres add-on <https://elements.heroku.com/addons/heroku-postgresql>`_,
1. `Scheduler add-on <https://devcenter.heroku.com/articles/scheduler>`_

You can also optionally configure the following add-ons (or simply set their secret keys in your config variables):

1. `SendGrid add-on <https://elements.heroku.com/addons/sendgrid>`_ for sending emails
1. `Honeybadger add-on <https://elements.heroku.com/addons/honeybadger>`_ for error reporting

Once you've pushed your application to Heroku and provisioned the appropriate add-ons,
you're ready to update your config with the appropriate secrets.
For a list of the expected secret key names, see your app.json file.

We will not cover Portico, as this requires that your application is a part of the openjournals organization.
If you do not already have access to these keys, you can simply ignore them for now.

.. note:
    One key we have not covered thus far is WHEDON_SECRET.
    This is because this is a secret key that you set yourself;
    for example, using something like a random SHA1 string.

    It is important to remember this key,
    as we will need it when deploying your Whedon-API application.

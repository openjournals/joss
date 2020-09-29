Installing the JOSS application
===============================

Any open journal (JOSS, JOSE, etc.) can be considered in three parts:

1. The website
2. The Whedon gem
3. A thin API wrapper around the Whedon gem to interface with GitHub

For JOSS, these correspond to the:

1. [JOSS](https://github.com/openjournals/joss),
2. [Whedon](https://github.com/openjournals/whedon), and
3. [Whedon-API](https://github.com/openjournals/whedon-api)

code bases.

Setting up a local development environment
------------------------------------------

All open journals are coded in Ruby,
with the website and Whedon-API developed as
[Ruby on Rails](https://rubyonrails.org/inst) applications.

If you'd like to develop these locally,
you'll need a working Ruby on Rails development environment.
For more information, please see
[this official guide](https://guides.rubyonrails.org/getting_started.html#creating-a-new-rails-project-installing-rails).

Deploying your JOSS application
-------------------------------

To deploy JOSS, you'll need a [Heroku account](https://signup.heroku.com/).
We also recommend you gather the following information
before deploying your application to Heroku:

1. A [public ORCID API](https://members.orcid.org/api/about-public-api) key
1. A GitHub [Personal Access Token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) for the automated account that users will interact with (e.g., `@Whedon`, `@RoboNeuro`)
1. An email address registered on a domain you control (i.e., not `gmail` or a related service)

```eval_rst
.. warning::
    Do not put these secrets directly into your code base!
    It is important that these keys are not under version control.

    There are different ways to make sure your application has access to these keys,
    depending on whether your code is being developed locally or on Heroku.
    Locally, you can store these locally in a .env file.
    The .gitignore in JOSS is already set to ignore this file type.

    On Heroku, they will be config variables that you can set either with the Heroku CLI or directly on your application's dashboard.
    See `this guide from Heroku <https://devcenter.heroku.com/articles/config-vars#managing-config-vars>`_ for more information.
```

Assuming you [have forked the JOSS GitHub repository](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo)
to your account, you can [configure Heroku as a git remote](https://devcenter.heroku.com/articles/git#prerequisites-install-git-and-the-heroku-cli) for your code.
This makes it easy to keep your Heroku deployment in sync with your local development copy.

On the JOSS Heroku deployment, you'll need to provision several [add-ons](https://elements.heroku.com/addons).
Specifically, you'll need an:

1. [Elasticsearch add-on](https://elements.heroku.com/addons/bonsai),
1. [Postgres add-on](https://elements.heroku.com/addons/heroku-postgresql),
1. [Scheduler add-on](https://devcenter.heroku.com/articles/scheduler)

For the scheduler add-on, you'll need to designate which tasks it should run and when.
These can be found in the `lib/tasks` folder, and involve things such as sending out weekly reminder emails to editors.
Each task should be scheduled as a separate job; for example, `rake send_weekly_emails`.

You can also optionally configure the following add-ons (or simply set their secret keys in your config variables):

1. [SendGrid add-on](https://elements.heroku.com/addons/sendgrid) for sending emails
1. [Honeybadger add-on](https://elements.heroku.com/addons/honeybadger) for error reporting

Once you've pushed your application to Heroku and provisioned the appropriate add-ons,
you're ready to update your config with the appropriate secrets.
For a list of the expected secret key names, see the `app.json` file.

```eval_rst
.. warn:
    One "gotcha" when provisioning the Bonsai add-on is that it may only set the BONSAI_URL variable.
    Make sure that there is also an ELASTICSEARCH_URL which is set to the same address.
```

We will not cover Portico, as this requires that your application is a part of the `openjournals` organization.
If you do not already have access to these keys, you can simply ignore them for now.

```eval_rst
.. note:
    One secret key we have not covered thus far is WHEDON_SECRET.
    This is because it is not one that you obtain from a provide,
    but a secret key that you set yourself.
    We recommend using something like a random SHA1 string.

    It is important to remember this key,
    as you will need it when deploying your Whedon-API application.
```

After pushing your application to Heroku, provisioning the appropriate add-ons,
and confirming that your config variables are set correctly,
you should make sure that your username is registered as an admin on the application.

You can do this on a local Rails console, by logging in and setting the boolean field 'admin'
on your user ID to True.
If you'd prefer to do this on the Heroku deployment, make sure you've logged into the application.
Then you can directly modify this attribute in the deployments Postgres database using SQL.
For more information on accessing your application's Postgres database,
see [the official docs](https://devcenter.heroku.com/articles/heroku-postgresql#pg-psql).

Making modifications to launch your own site
--------------------------------------------

Some times you may not want to launch an exact copy of JOSS, but a modified version.
This can be especially useful if you're planning to spin up your own platform based on the
Open Journals framework.
[NeuroLibre](https://neurolibre.herokuapp.com) is one such example use-case.

In this case, there are several important variables to be aware of and modify.
Most of these are accessible in the `config` folder.

First, there are three files which provide settings for your Rails application in different development contexts:

1. `settings-test.yml`
1. `settings-development.yml`
1. `settings-production.yml`

These each contain site-specific variables that should be modified if you are building off of the Open Journals framework.

Next, you'll need to modify the `repository.yml` file.
This file lists the GitHub repository where you expect papers to be published,
as well as the editor team ID.
For your GitHub organization, make sure you have created and populated a team called `editors`.
Then, you can check its ID number as detailed in [this guide](https://fabian-kostadinov.github.io/2015/01/16/how-to-find-a-github-team-id).

Finally, you can modify the `orcid.yml` file to list your site as the production site.
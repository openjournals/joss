# The Journal of Open Source Software

[![Build Status](https://github.com/openjournals/joss/actions/workflows/tests.yml/badge.svg)](https://github.com/openjournals/joss/actions/workflows/tests.yml)
[![Powered by NumFOCUS](https://img.shields.io/badge/powered%20by-NumFOCUS-orange.svg?style=flat&colorA=E1523D&colorB=007D8A)](http://numfocus.org)
[![Donate to JOSS](https://img.shields.io/badge/Donate-to%20JOSS-brightgreen.svg)](https://numfocus.org/donate-to-joss)

The [Journal of Open Source Software](https://joss.theoj.org) (JOSS) is a developer friendly journal for research software packages.

### What exactly do you mean by 'journal'

The Journal of Open Source Software (JOSS) is an academic journal with a formal peer review process that is designed to _improve the quality of the software submitted_. Upon acceptance into JOSS, a CrossRef DOI is minted and we list your paper on the JOSS website.

### Don't we have enough journals already?

In a perfect world, papers about software wouldn't be necessary. Unfortunately, for most researchers, academic currency relies on papers rather than software and citations are, thus, crucial for a successful career.

We built this journal because we believe that after you've done the hard work of writing great software, it shouldn't take weeks and months to write a paper<sup>1</sup> about your work.

### You said developer friendly, what do you mean?

We have a simple submission workflow and extensive documentation to help you prepare your submission. If your software is already well documented then paper preparation should take no more than an hour.

<sup>1</sup> After all, this is just advertising.

## The site

The JOSS submission tool is hosted at https://joss.theoj.org

## JOSS Reviews

If you're looking for the JOSS reviews repository head over here: https://github.com/openjournals/joss-reviews/issues

## Code of Conduct

In order to have a more open and welcoming community, JOSS adheres to a code of conduct adapted from the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

Please adhere to this code of conduct in any interactions you have in the JOSS community. It is strictly enforced on all official JOSS repositories, the JOSS website, and resources. If you encounter someone violating these terms, please let the Editor-in-Chief ([@arfon](https://github.com/arfon)) or someone on the [editorial board](https://joss.theoj.org/about#editorial_board) know and we will address it as soon as possible.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## ⚙️ Development

[PostgreSQL](https://www.postgresql.org/) and [Elasticsearch](https://www.elastic.co/elasticsearch/) should be installed and running locally for JOSS to work

1. Install packages with bundler - `bundle install`
2. Set rails env in your shell (or prepend to each command): `export RAILS_ENV=development`
3. Create the database with `bin/rails db:create`
4. Run any pending db migrations `bin/rails db:migrate`
5. (Optional) seed the data with demo data (see `db/seeds.rb`) `bin/rails db:seed`
6. After running elasticsearch, create an index with `curl -X PUT http://localhost:9200/joss-production`
   Note - you may need to disable the default security settings of elasticsearch by editing your `config/elasticsearch.yml`
7. Create search indexes: `bin/rails searchkick:reindex:all`
8. Run `bin/rails s`

### MacOS Notes

You may encounter an error on startup like:

```
Started GET "/" for 127.0.0.1 at 2024-08-15 13:03:02 -0700
objc[41226]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called.
objc[41226]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
```

To resolve it, either in your shell file or in the shell itself add:

```azure
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```

See [rails#38560](https://github.com/rails/rails/issues/38560)

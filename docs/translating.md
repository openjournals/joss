# Contributing to Translation

These docs and the main journal website welcome corrections or translations into
additional languages.

Both are available in the same repository [openjournals/joss](https://github.com/openjournals/joss)
with slightly different contributor workflows:

## Python Docs

The documents in the `docs` directory (this site) are built with `sphinx`
and internationalized with `sphinx-intl`. These translations use standard
`gettext`-style `.pot` and `.po` files. 

The `.pot` files are generated from the source pages on each update and not versioned,
and the translations are contained within `.po` files in the `locale` directory.
A CI action ensures that any change to the english source text is reflected in
the generated `.po` files.

### Adding a new language

- Install the requirements, ideally in a virtual environment: 
  `python -m pip install -r requirements.txt`
- Add a new [ISO-639](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes) code
  to the `languages` list in `conf.py`
- Run `make i18n` (which just calls `update_i18n.py`) to generate the `.po` files
- Open a PR with the empty `.po` files - the maintainers of the site will have to add
  the new language as a [readthedocs project](https://docs.readthedocs.io/en/stable/localization.html#projects-with-multiple-translations),
  so this early PR gives them time to get that ready by the time the translation is relatively complete
- Work on the translations in the `.po` files!

### Translating

You can run the `sphinx-intl stat` command to get a sense of what
files need the most work:

From `docs`:

```shell
$ sphinx-intl stat -l es
locale/es/LC_MESSAGES/sample_messages.po: 0 translated, 0 fuzzy, 8 untranslated.
locale/es/LC_MESSAGES/review_criteria.po: 0 translated, 0 fuzzy, 61 untranslated.
locale/es/LC_MESSAGES/editor_onboarding.po: 0 translated, 0 fuzzy, 88 untranslated.
locale/es/LC_MESSAGES/editor_tips.po: 0 translated, 0 fuzzy, 21 untranslated.
locale/es/LC_MESSAGES/expectations.po: 0 translated, 0 fuzzy, 24 untranslated.
locale/es/LC_MESSAGES/installing.po: 0 translated, 0 fuzzy, 73 untranslated.
locale/es/LC_MESSAGES/policies.po: 0 translated, 0 fuzzy, 9 untranslated.
locale/es/LC_MESSAGES/example_paper.po: 0 translated, 0 fuzzy, 5 untranslated.
locale/es/LC_MESSAGES/reviewer_guidelines.po: 0 translated, 0 fuzzy, 13 untranslated.
locale/es/LC_MESSAGES/editing.po: 0 translated, 0 fuzzy, 134 untranslated.
locale/es/LC_MESSAGES/index.po: 0 translated, 0 fuzzy, 20 untranslated.
locale/es/LC_MESSAGES/submitting.po: 0 translated, 0 fuzzy, 80 untranslated.
locale/es/LC_MESSAGES/paper.po: 0 translated, 0 fuzzy, 150 untranslated.
locale/es/LC_MESSAGES/venv.po: 0 translated, 0 fuzzy, 136 untranslated.
locale/es/LC_MESSAGES/review_checklist.po: 0 translated, 0 fuzzy, 29 untranslated.
locale/es/LC_MESSAGES/editorial_bot.po: 0 translated, 0 fuzzy, 69 untranslated.
```

See the [pyopensci `TRANSLATING.md` guide in the `python-package-guide`](https://github.com/pyOpenSci/python-package-guide/blob/main/TRANSLATING.md)
for further instructions!

After you are finished, run `make i18n` again to reformat your strings
to fit the standard style that the CI will check for.

## JOSS Website

```{admonition}
TODO!
```
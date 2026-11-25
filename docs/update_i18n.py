"""
Script to update i18n files.
"""

import argparse
from pathlib import Path
import subprocess

from sphinx_intl.basic import update

import conf

SOURCE_DIR = Path(__file__).parent.resolve()
LOCALES_DIR = SOURCE_DIR / 'locale'
BUILD_DIR = SOURCE_DIR / '_build'
TEMPLATE_DIR = BUILD_DIR / "gettext"


def make_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Update i18n files for JOSS docs",
    )
    parser.add_argument(
        '-l', '--lang',
        help="Language code (one of the enabled languages in conf.py:languages). "
            "If ``None``, update all languages. Argument may be passed multiple times for multiple languages",
        action="append",
        default=None
    )
    return parser

def update_pot():
    """
    Update .pot template files
    """
    res = subprocess.run(['sphinx-build', '-b', 'gettext', str(SOURCE_DIR), str(TEMPLATE_DIR)], capture_output=True)
    if res.returncode != 0:
        raise OSError("Error updating .pot files:\n" + res.stderr)


def main():
    parser = make_parser()
    args = parser.parse_args()

    if not args.lang:
        languages = conf.languages
    else:
        languages = args.lang

    update_pot()
    update(LOCALES_DIR, TEMPLATE_DIR, languages)

if __name__ == '__main__':
    main()
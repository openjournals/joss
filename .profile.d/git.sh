# Heroku-24 has no git at runtime; it is installed by heroku-community/apt (see Aptfile).
# apt-installed git looks for its helpers (e.g. git-remote-https) under /usr/lib/git-core,
# which does not exist on the dyno, so point it at the vendored copy.
export GIT_EXEC_PATH="$HOME/.apt/usr/lib/git-core"
export GIT_TEMPLATE_DIR="$HOME/.apt/usr/share/git-core/templates"

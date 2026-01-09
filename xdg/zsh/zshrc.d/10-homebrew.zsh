# Homebrew: initialize PATH/env once, even if brew isn't on PATH yet.
brew_bin=""

if (( $+commands[brew] )); then
  brew_bin="$(command -v brew)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  brew_bin="/opt/homebrew/bin/brew"
elif [[ -x /usr/local/bin/brew ]]; then
  brew_bin="/usr/local/bin/brew"
fi

if [[ -n "$brew_bin" ]]; then
  # Only run shellenv if Homebrew env vars aren't already present.
  if [[ -z "${HOMEBREW_PREFIX-}" || -z "${HOMEBREW_CELLAR-}" || -z "${HOMEBREW_REPOSITORY-}" ]]; then
    eval "$("$brew_bin" shellenv)"
  fi
fi
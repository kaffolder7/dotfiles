# Homebrew: fast init using a cached shellenv, with fallback when brew isn't on PATH yet.
brew_bin=""

if (( $+commands[brew] )); then
  brew_bin="$(command -v brew)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  brew_bin="/opt/homebrew/bin/brew"
elif [[ -x /usr/local/bin/brew ]]; then
  brew_bin="/usr/local/bin/brew"
fi

if [[ -n "$brew_bin" ]]; then
  cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  cache_file="$cache_dir/brew-shellenv.zsh"
  mkdir -p "$cache_dir"

  # Only (re)generate cache when needed
  if [[ ! -f "$cache_file" || "$brew_bin" -nt "$cache_file" ]]; then
    "$brew_bin" shellenv >| "$cache_file" 2>/dev/null
  fi

  source "$cache_file"
fi
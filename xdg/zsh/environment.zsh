export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export DOTFILES_DIR="${${(%):-%N}:A:h:h:h}"
[[ -r "$XDG_CONFIG_HOME/dotfiles/host" ]] && export DOTFILES_HOST="$(<"$XDG_CONFIG_HOME/dotfiles/host")"
if [[ -x /opt/homebrew/bin/brew ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
elif [[ -x /usr/local/bin/brew ]]; then
  export HOMEBREW_PREFIX=/usr/local
fi
if [[ -n "${HOMEBREW_PREFIX:-}" && "${_DOTFILES_BREW_ENV:-}" != "$HOMEBREW_PREFIX" ]]; then
  eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
  typeset -g _DOTFILES_BREW_ENV="$HOMEBREW_PREFIX"
fi
typeset -U path fpath cdpath manpath
# Detach the shell while Nix remains installed for the separate removal step.
path=( ${path:#/nix/*} )
path=( ${path:#$HOME/.nix-profile/*} )
path=( ${path:#/etc/profiles/per-user/*} )
fpath=( ${fpath:#/nix/*} )
fpath=( ${fpath:#$HOME/.nix-profile/*} )
manpath=( ${manpath:#/nix/*} )
manpath=( ${manpath:#$HOME/.nix-profile/*} )
unset DOTFILES_ROUTE __HM_SESS_VARS_SOURCED __HM_ZSH_SESS_VARS_SOURCED
unset NIX_PROFILES NIX_PATH NIX_SSL_CERT_FILE NIX_USER_PROFILE_DIR __ETC_PROFILE_NIX_SOURCED
[[ "${SSL_CERT_FILE:-}" == /nix/* ]] && unset SSL_CERT_FILE
[[ "${HELPDIR:-}" == /nix/* ]] && unset HELPDIR
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  path=( "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" $path )
  [[ -d "$HOMEBREW_PREFIX/opt/curl/bin" ]] && path=( "$HOMEBREW_PREFIX/opt/curl/bin" $path )
  fpath=( "$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath )
  export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home"
  [[ -d "$JAVA_HOME/bin" ]] && path=( "$JAVA_HOME/bin" $path )
fi
path=( "${MISE_DATA_DIR:-$XDG_DATA_HOME/mise}/shims" "$XDG_BIN_HOME" $path )
export PATH
export EDITOR=nvim VISUAL=nvim
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export DOCKER_CONFIG="${DOCKER_CONFIG:-$HOME/.docker}"

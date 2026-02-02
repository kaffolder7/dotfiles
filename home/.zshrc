# ---- Output-producing stuff MUST be above instant prompt ----

# Keep fast prompt, suppress warning
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Optional: only show in Ghostty (avoid ssh, tmux, etc.)
if [[ -o interactive ]] && [[ "${TERM_PROGRAM-}" == "ghostty" ]]; then
  command -v fastfetch >/dev/null && fastfetch --pipe false
fi

# Powerlevel10k instant prompt (must be near the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Interactive-only from here down
[[ -o interactive ]] || return

# XDG base (define early so everything can use it)
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Source modular config
local ZSHRC_DIR="$XDG_CONFIG_HOME/zsh/zshrc.d"
if [[ -d "$ZSHRC_DIR" ]]; then
  for f in "$ZSHRC_DIR"/*.zsh(N); do
    source "$f"
  done
fi
unset f

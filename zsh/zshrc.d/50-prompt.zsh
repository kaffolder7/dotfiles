[[ -n "${HOMEBREW_PREFIX-}" ]] || return

[[ -r "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme" ]] &&
  source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"

# Load p10k config if present
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
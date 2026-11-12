typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
if [[ -r "${HOMEBREW_PREFIX:-}/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
  if [[ -r "$HOME/.p10k.zsh" ]]; then
    source "$HOME/.p10k.zsh"
  else
    source "$XDG_CONFIG_HOME/zsh/.p10k.zsh"
  fi
fi

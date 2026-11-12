# Load after widgets, plugins, and local overrides.
if [[ -r "${HOMEBREW_PREFIX:-}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

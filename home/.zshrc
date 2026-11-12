# Restore precedence after macOS global startup files.
source "${${(%):-%N}:A:h:h}/xdg/zsh/environment.zsh"
[[ -o interactive ]] || return
if [[ "${TERM_PROGRAM:-}" == ghostty ]] && (( $+commands[fastfetch] )); then
  command fastfetch --pipe false
fi
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi
for module in "$XDG_CONFIG_HOME/zsh/zshrc.d/"*.zsh(N); do
  source "$module"
done
unset module

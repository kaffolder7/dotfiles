[[ "${DOTFILES_ROUTE-}" == "hm" ]] && return

# Run fastfetch once per interactive session (and not before instant prompt)
autoload -Uz add-zsh-hook

_run_fastfetch_once() {
  add-zsh-hook -d precmd _run_fastfetch_once
  command -v fastfetch >/dev/null && command fastfetch --pipe false
}
add-zsh-hook precmd _run_fastfetch_once
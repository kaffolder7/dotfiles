(( $+commands[fzf] )) && source <(command fzf --zsh)
(( $+commands[zoxide] )) && eval "$(command zoxide init zsh --cmd cd)"
(( $+commands[direnv] )) && eval "$(command direnv hook zsh)"

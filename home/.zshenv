# Quiet environment for interactive shells and IDE subprocesses.
source "${${(%):-%N}:A:h:h}/xdg/zsh/environment.zsh"
[[ -r "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"

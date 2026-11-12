# macOS path_helper runs before this file.
source "${${(%):-%N}:A:h:h}/xdg/zsh/environment.zsh"
[[ -r "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"

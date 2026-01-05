# Path arrays as unique (no dupes)
typeset -U path cdpath fpath manpath

# Zsh cache dirs
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_CACHE_HOME/zsh/zcompcache"
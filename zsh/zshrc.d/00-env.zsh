# Path arrays as unique (no dupes)
typeset -U path cdpath fpath manpath

# Zsh cache dirs
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zcompdump-$ZSH_VERSION"
mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_CACHE_HOME/zsh/zcompcache"
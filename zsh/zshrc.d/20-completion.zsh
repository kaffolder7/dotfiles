# Completion caching helps a lot (set styles before compinit)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' rehash true

# Helps with menu selection / nicer completion lists
zmodload zsh/complist 2>/dev/null

autoload -Uz compinit
compinit -C -d "$ZSH_COMPDUMP"
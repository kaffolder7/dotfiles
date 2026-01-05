HISTSIZE=10000
SAVEHIST=10000

# HISTFILE="$XDG_CONFIG_HOME/zsh/.zsh_history"
HISTFILE="$XDG_STATE_HOME/zsh/history"
mkdir -p "${HISTFILE:h}"

setopt HIST_FCNTL_LOCK

# Enabled history options
for opt in EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY autocd; do
  setopt "$opt"
done

# Disabled history options
for opt in HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS; do
  unsetopt "$opt"
done
unset opt
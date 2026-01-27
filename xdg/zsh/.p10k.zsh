# Minimal P10k config focused on speed
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

# VCS can be expensive in huge repos; this keeps it reasonable
typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=50000  # -1 is unlimited
typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'

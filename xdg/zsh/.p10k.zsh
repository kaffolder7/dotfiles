# =============================================================================
# Powerlevel10k Configuration
# =============================================================================
#
# Minimal but functional P10k config focused on speed.
# Run `p10k configure` for the interactive wizard, or customize below.
#
# Documentation: https://github.com/romkatv/powerlevel10k
#

# -----------------------------------------------------------------------------
# Instant Prompt Mode
# -----------------------------------------------------------------------------
# - 'verbose': Print warnings when console output is detected during init
# - 'quiet': Silently redirect early output (recommended)
# - 'off': Disable instant prompt
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Disable the configuration wizard
typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# -----------------------------------------------------------------------------
# Prompt Segments
# -----------------------------------------------------------------------------
# Left prompt: directory and git status
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir           # Current directory
  vcs           # Git status
)

# Right prompt: command status, background jobs, time (optional)
# typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status              # Exit code of last command
  command_execution_time  # How long the last command took
  background_jobs     # Number of background jobs
  # direnv            # direnv status (if using direnv)
  # nix_shell         # Nix shell indicator
  # time              # Current time
)

# -----------------------------------------------------------------------------
# Directory Segment
# -----------------------------------------------------------------------------
# Shorten directory path
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3

# Directory colors
typeset -g POWERLEVEL9K_DIR_FOREGROUND=31
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=103
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39

# Show anchor directories in bold
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

# -----------------------------------------------------------------------------
# VCS (Git) Segment
# -----------------------------------------------------------------------------
# Only show on Git repos
typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

# Performance: limit dirty checking in large repos
typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=50000 # -1 is unlimited

# Disable git status in home directory (too slow with large dotfiles)
typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'

# Git status indicators
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=178

# Branch icon (optional, requires Nerd Font)
# typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '

# -----------------------------------------------------------------------------
# Status Segment
# -----------------------------------------------------------------------------
# Only show on error
typeset -g POWERLEVEL9K_STATUS_OK=false
typeset -g POWERLEVEL9K_STATUS_ERROR=true
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=196

# -----------------------------------------------------------------------------
# Command Execution Time
# -----------------------------------------------------------------------------
# Only show if command took longer than 3 seconds
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=101

# Precision (number of decimal places)
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1

# Human-readable format (e.g., "2m 30s" instead of "150s")
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

# -----------------------------------------------------------------------------
# Background Jobs
# -----------------------------------------------------------------------------
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=37

# -----------------------------------------------------------------------------
# Prompt Style
# -----------------------------------------------------------------------------
# Prompt on a single line (faster)
typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false

# No separators for cleaner look
typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '

# Add a space before the prompt character
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '

# Prompt character
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196

# -----------------------------------------------------------------------------
# Transient Prompt (optional)
# -----------------------------------------------------------------------------
# Show a simplified prompt for previous commands
# typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir

# -----------------------------------------------------------------------------
# Nix Shell Segment (optional)
# -----------------------------------------------------------------------------
# Uncomment if you use nix-shell or nix develop frequently
# typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND=74

# -----------------------------------------------------------------------------
# Direnv Segment (optional)
# -----------------------------------------------------------------------------
# Uncomment if you want direnv status in prompt
# typeset -g POWERLEVEL9K_DIRENV_FOREGROUND=178

(( $+commands[mise] )) && eval "$(command mise activate zsh)"
typeset -a dotfiles_sdks
dotfiles_sdks=( "$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/"connectiq-sdk-*(N/n) )
if (( ${#dotfiles_sdks} )); then
  export CONNECTIQ_HOME="${dotfiles_sdks[-1]}"
  path=( "$CONNECTIQ_HOME/bin" $path )
fi
unset dotfiles_sdks

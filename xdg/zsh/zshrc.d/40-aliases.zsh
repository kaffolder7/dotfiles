alias code=zed
alias vi=nvim vim=nvim vimdiff='nvim -d'
alias fd='fd --hidden'
alias eza='eza --icons=auto --git --git-repos --group-directories-first --header'
alias ls=eza l='eza -lah' ll='eza -lao' la='eza -la' lla='eza -la' lt='eza --tree --level=2'
alias g=git gs='git status' gd='git diff' ga='git add' gc='git commit'
alias gp='git push' gl='git pull' gco='git checkout' gb='git branch'
alias glog='git log --oneline --graph --decorate'
alias ..='cd ..' ...='cd ../..' ....='cd ../../..'
alias rm='rm -i' cp='cp -i' mv='mv -i'
alias reload='exec zsh -l' path='print -l $path'
# Homebrew b2-tools supplies b2 directly.

#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
brew update
brew bundle --file="$ROOT/Brewfile"
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/vscode" ]]; then
  brew bundle --file="$ROOT/Brewfile.vscode"
fi
cd "$HOME"
mise install
mise upgrade node
uv python upgrade 3.14
printf '%s\n' 'Happy is pinned in xdg/mise/config.toml; review a version bump before upgrading it.'

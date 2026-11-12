#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
for file in install.sh bin/dot bin/dot-doctor scripts/update.sh scripts/test.sh; do
  bash -n "$file"
done
for file in home/.zshenv home/.zprofile home/.zshrc xdg/zsh/environment.zsh xdg/zsh/zshrc.d/*.zsh; do
  zsh -n "$file"
done
python3 -m unittest discover -s tests -v
ruby -c Brewfile
ruby -c Brewfile.vscode
make -n install update doctor audit

#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Prefer uv's Python. Command Line Tools provide the bootstrap fallback.
for candidate in "$HOME/.local/bin/python3" /opt/homebrew/bin/python3 /usr/local/bin/python3 /usr/bin/python3; do
  if [[ -x "$candidate" ]]; then
    exec "$candidate" "$ROOT/scripts/install.py" "$@"
  fi
done
echo 'Python 3 required. Install Command Line Tools: xcode-select --install' >&2
exit 1

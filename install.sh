#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--brew] [--force]

  --brew   Run Homebrew Bundle (Brewfile) if brew is available (or install brew if missing).
  --force  Overwrite existing files (default is to back them up).
EOF
}

RUN_BREW=0
FORCE=0
for arg in "${@:-}"; do
  case "$arg" in
    --brew)  RUN_BREW=1 ;;
    --force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $arg" >&2; usage; exit 2 ;;
  esac
done

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  echo "Homebrew not found. Installing Homebrew..." >&2
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  command -v brew >/dev/null 2>&1
}

run_brew_bundle() {
  ensure_brew || { echo "brew still not available; skipping Brewfile." >&2; return 0; }
  echo "Running: brew bundle --file \"$DOTFILES_DIR/Brewfile\"" >&2
  brew bundle --file "$DOTFILES_DIR/Brewfile"
}

link() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  # If dst is a symlink already pointing at src, do nothing.
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    echo "ok: $dst already -> $src"
    return 0
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      rm -rf "$dst"
    else
      local backup="${dst}.bak.$(date %Y%m%d%H%M%S)"
      mv "$dst" "$backup"
      echo "backed up: $dst -> $backup"
    fi
  fi

  ln -s "$src" "$dst"
  echo "linked: $dst -> $src"
}

# Optional: install apps first (so shell plugins exist before first shell start)
if [[ "$RUN_BREW" -eq 1 ]]; then
  run_brew_bundle
fi

# ---- Symlink dotfiles ----

# Zsh modules live under XDG config (matches zsh/.zshrc)
link "$DOTFILES_DIR/zsh/zshrc.d" "$HOME/.config/zsh/zshrc.d"

# Optional backwards-compat link (harmless, but not required)
# link "$DOTFILES_DIR/zsh/zshrc.d" "$HOME/.zshrc.d"

link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
# link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
link "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
link "$DOTFILES_DIR/nano/nanorc" "$HOME/.config/nano/nanorc"

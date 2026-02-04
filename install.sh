#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ----------------------------
# CLI args
# ----------------------------
usage() {
  cat <<'EOF'
Usage: ./install.sh [--brew] [--force] [--yes] [--method homebrew|nix]

  --brew                 Run Homebrew Bundle (Brewfile). Installs brew if missing (macOS).
  --force                Overwrite existing files (default is to back them up).
  --yes                  Skip the initial "begin setup?" prompt.
  --method homebrew|nix   On macOS, select setup method without prompting (default: homebrew).

Examples:
  ./install.sh --brew
  ./install.sh --force --brew
  ./install.sh --yes --method nix
EOF
}

RUN_BREW=0
FORCE=0
ASSUME_YES=0
METHOD=""  # "homebrew" or "nix" (macOS only)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --brew)  RUN_BREW=1; shift ;;
    --force) FORCE=1; shift ;;
    --yes)   ASSUME_YES=1; shift ;;
    --method)
      METHOD="${2:-}"
      [[ -n "$METHOD" ]] || { echo "Missing value for --method" >&2; usage; exit 2; }
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

# ----------------------------
# Helpers
# ----------------------------
log()  { printf "\033[1;34m[setup]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[error]\033[0m %s\n" "$*"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }
is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux() { [[ "$(uname -s)" == "Linux" ]]; }

user_bin_dir() {
  # Prefer XDG-ish user bin if present; otherwise fall back.
  # (We intentionally avoid /usr/local/bin to keep this non-root and non-destructive.)
  echo "${XDG_BIN_HOME:-$HOME/.local/bin}"
}

ensure_user_bin_on_path_hint() {
  local bindir
  bindir="$(user_bin_dir)"
  if [[ ":$PATH:" != *":$bindir:"* ]]; then
    warn "Your PATH does not include: $bindir"
    warn "Add this to your shell (e.g. ~/.zshrc.local):"
    warn "  export PATH=\"$bindir:\$PATH\""
  fi
}

install_dot_cli() {
  local bindir
  bindir="$(user_bin_dir)"
  mkdir -p "$bindir"

  # Ensure scripts are executable in the repo (best-effort; ok if git already preserves this)
  chmod +x "$DOTFILES_DIR/bin/dot" "$DOTFILES_DIR/bin/dot-doctor" 2>/dev/null || true

  link "$DOTFILES_DIR/bin/dot"        "$bindir/dot"
  link "$DOTFILES_DIR/bin/dot-doctor" "$bindir/dot-doctor"

  ensure_user_bin_on_path_hint
}

# Prompt for yes/no with default (Y or n)
# Usage: confirm "Question?" "Y"  -> returns 0 if yes, 1 if no
confirm() {
  local prompt="${1:?prompt required}"
  local default="${2:-Y}" # "Y" or "n"

  local suffix=""
  case "$default" in
    Y|y) suffix=" [Y/n]" ;;
    n|N) suffix=" [y/N]" ;;
    *) suffix=" [Y/n]" ;;
  esac

  while true; do
    read -r -p "${prompt}${suffix} " reply || true
    reply="${reply:-$default}"

    case "$reply" in
      Y|y|yes|YES) return 0 ;;
      N|n|no|NO)   return 1 ;;
      *) warn "Please answer y or n." ;;
    esac
  done
}

# Prompt for a choice with default
# Usage: choice=$(choose "Pick one" "defaultValue" "a" "b" "c")
choose() {
  local prompt="${1:?prompt required}"
  local default="${2:?default required}"
  shift 2
  local options=("$@")

  local opts_str
  opts_str="$(printf "%s/" "${options[@]}")"
  opts_str="${opts_str%/}"

  while true; do
    read -r -p "${prompt} [${opts_str}] (default: ${default}): " reply || true
    reply="${reply:-$default}"

    for opt in "${options[@]}"; do
      if [[ "$reply" == "$opt" ]]; then
        printf "%s" "$reply"
        return 0
      fi
    done

    warn "Invalid selection: '$reply'"
  done
}

ensure_curl() {
  if command_exists curl; then return 0; fi

  if is_macos; then
    err "curl not found — unexpected on macOS. Install Xcode Command Line Tools?"
    exit 1
  fi

  if command_exists apt-get; then
    sudo apt-get update && sudo apt-get install -y curl
  elif command_exists dnf; then
    sudo dnf install -y curl
  elif command_exists yum; then
    sudo yum install -y curl
  elif command_exists pacman; then
    sudo pacman -Sy --noconfirm curl
  else
    err "curl is required but I don't know how to install it on this system."
    exit 1
  fi
}

ensure_secret_reminder() {
  local name="$1"                 # e.g. openai_api_key
  local example_rel="${2:-}"      # e.g. secrets/openai_api_key.example
  local label="${3:-$name}"       # e.g. "OpenAI API key"

  local secrets_dir="$HOME/.config/secrets"
  local key_file="$secrets_dir/$name"

  mkdir -p "$secrets_dir"
  chmod 700 "$secrets_dir" || true

  if [[ ! -f "$key_file" ]]; then
    warn "$label not found."
    warn "Create it at: $key_file"
    if [[ -n "$example_rel" ]]; then
      warn "Example in repo: $DOTFILES_DIR/$example_rel"
    fi
  else
    # Best-effort perms check (macOS + Linux)
    local perms=""
    perms="$(stat -f %Lp "$key_file" 2>/dev/null || stat -c %a "$key_file" 2>/dev/null || true)"
    if [[ -n "$perms" && "$perms" != "600" ]]; then
      warn "$label file permissions should be 600 (currently $perms): $key_file"
      warn "Fix with: chmod 600 \"$key_file\""
    fi
  fi
}

# ----------------------------
# Installers
# ----------------------------
ensure_brew() {
  if command_exists brew; then
    return 0
  fi
  if ! is_macos; then
    warn "brew not found and you're not on macOS; skipping brew install."
    return 1
  fi

  ensure_curl
  log "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  command_exists brew
}

run_brew_bundle() {
  ensure_brew || { warn "brew still not available; skipping Brewfile."; return 0; }
  log "Running: brew bundle --file \"$DOTFILES_DIR/Brewfile\""
  brew bundle --file "$DOTFILES_DIR/Brewfile"
}

install_determinate_nix_macos() {
  if command_exists nix; then
    log "Nix already installed."
    return 0
  fi

  ensure_curl
  log "Installing Determinate Nix (macOS)..."
  curl --proto '=https' --tlsv1.2 -fsSf -L https://install.determinate.systems/nix | sh -s -- install

  # Try to load nix into this shell session (best-effort)
  if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  elif [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    # shellcheck disable=SC1091
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi

  log "Determinate Nix install complete."
}

# --- Nix config helpers (macOS Determinate Nix) ---

# Try to locate the nix.conf that actually governs the daemon install.
# On macOS daemon installs, /etc/nix/nix.conf is typical.
nix_conf_path() {
  if [[ -f /etc/nix/nix.conf ]]; then
    echo "/etc/nix/nix.conf"
  elif [[ -f "$HOME/.config/nix/nix.conf" ]]; then
    echo "$HOME/.config/nix/nix.conf"
  else
    # Prefer system-level location if it exists as a dir (daemon-style)
    if [[ -d /etc/nix ]]; then
      echo "/etc/nix/nix.conf"
    else
      echo "$HOME/.config/nix/nix.conf"
    fi
  fi
}

# Ensure flakes + nix-command are enabled.
# Determinate Nix typically enables this by default, but we enforce it to avoid surprises.
ensure_nix_flakes_enabled() {
  local conf
  conf="$(nix_conf_path)"

  # Ensure parent dir exists (user-level config)
  if [[ "$conf" == "$HOME"* ]]; then
    mkdir -p "$(dirname "$conf")"
    touch "$conf"
  fi

  local begin="# BEGIN dotfiles install.sh"
  local end="# END dotfiles install.sh"
  local line="experimental-features = nix-command flakes"

  log "Ensuring Nix flakes enabled in $conf"

  # --- helpers (local to this function) ---

  # returns 0 if both begin+end exist, else 1
  _has_complete_block() {
    local use_sudo=0
    if [[ "${1:-}" == "--sudo" ]]; then
      use_sudo=1
      shift
    fi

    local file="${1:?file path required}"
    local begin_marker="${2:?begin marker required}"
    local end_marker="${3:?end marker required}"

    local -a run=()
    if [[ "$use_sudo" -eq 1 ]]; then
      run=(sudo)
    fi

    "${run[@]}" grep -Fq "$begin_marker" "$file" \
      && "${run[@]}" grep -Fq "$end_marker" "$file"
  }

  _replace_block() {
    local file="$1"
    awk -v begin="$begin" -v end="$end" -v line="$line" '
      $0 == begin {inblock=1; print begin; print line; print end; next}
      $0 == end   {inblock=0; next}
      !inblock    {print}
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
  }

  _append_block() {
    local file="$1"
    {
      echo
      echo "$begin"
      echo "$line"
      echo "$end"
    } >>"$file"
  }

  # --- system-level config (/etc/nix/nix.conf) ---
  if [[ "$conf" == "/etc/"* ]]; then
    sudo mkdir -p "$(dirname "$conf")"
    sudo touch "$conf"

    if _has_complete_block --sudo "$conf" "$begin" "$end"; then
      # Replace existing managed block
      sudo awk -v begin="$begin" -v end="$end" -v line="$line" '
        $0 == begin {inblock=1; print begin; print line; print end; next}
        $0 == end   {inblock=0; next}
        !inblock    {print}
      ' "$conf" | sudo tee "${conf}.tmp" >/dev/null
      sudo mv "${conf}.tmp" "$conf"
    else
      # Append new managed block
      {
        echo
        echo "$begin"
        echo "$line"
        echo "$end"
      } | sudo tee -a "$conf" >/dev/null
    fi

  # --- user-level config (~/.config/nix/nix.conf) ---
  else
    if _has_complete_block "$conf" "$begin" "$end"; then
      _replace_block "$conf"
    else
      _append_block "$conf"
    fi
  fi
}

restart_nix_daemon_macos() {
  # Best-effort: only if launchctl + daemon label exists
  if command_exists launchctl; then
    sudo launchctl kickstart -k system/org.nixos.nix-daemon >/dev/null 2>&1 || true
  fi
}

# Run nix with flakes enabled even if config didn’t load yet
nix_with_flakes() {
  nix --extra-experimental-features "nix-command flakes" "$@"
}

install_home_manager_nix_macos() {
  # Pre-reqs
  if ! command_exists nix; then
    err "nix is not available. Did \`install_determinate_nix_macos\` run successfully?"
    return 1
  fi

  # 1) Enable flakes (config + fallback flags)
  ensure_nix_flakes_enabled
  restart_nix_daemon_macos

  # Ensure nix can talk to the daemon and has a profile initialized
  # (some fresh installs don’t have a profile until you run `nix profile ...`).
  nix_with_flakes profile list >/dev/null 2>&1 || true

  # 2) Install Home Manager standalone
  if command_exists home-manager; then
    log "home-manager already installed."
    return 0
  fi

  log "Installing Home Manager (standalone) into your user profile..."
  # Flake ref: install the home-manager package from the official repo
  # (This keeps the `home-manager` CLI available as a normal command.)
  nix_with_flakes profile install "github:nix-community/home-manager#home-manager"

  # Refresh current shell PATH if needed (usually unnecessary, but helps in non-login shells)
  hash -r || true

  if ! command_exists home-manager; then
    warn "home-manager wasn't found on PATH yet."
    warn "Try opening a new terminal, or ensure your shell sources Nix profile scripts."
  else
    log "Home Manager installed."
  fi
}

# ----------------------------
# Dotfile linking
# ----------------------------
link() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  # If dst is a symlink already pointing at src, do nothing.
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    log "ok: $dst already -> $src"
    return 0
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      rm -rf "$dst"
    else
      local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
      mv "$dst" "$backup"
      log "backed up: $dst -> $backup"
    fi
  fi

  ln -s "$src" "$dst"
  log "linked: $dst -> $src"
}

# Link only if source exists
# link_if_exists() {
#   local src="$1"
#   local dst="$2"
#   if [[ -e "$src" ]]; then
#     link "$src" "$dst"
#   else
#     log "skipped (not in repo): $src"
#   fi
# }

symlink_dotfiles() {
  # Zsh modules live under XDG config (matches zsh/.zshrc)
  link "$DOTFILES_DIR/xdg/zsh/zshrc.d" "$HOME/.config/zsh/zshrc.d"
  link "$DOTFILES_DIR/home/.zshrc" "$HOME/.zshrc"

  # Only link .gitconfig if it exists in repo
  [[ -f "$DOTFILES_DIR/home/.gitconfig" ]] && link "$DOTFILES_DIR/home/.gitconfig" "$HOME/.gitconfig"
  # link_if_exists "$DOTFILES_DIR/home/.gitconfig" "$HOME/.gitconfig"

  link "$DOTFILES_DIR/xdg/ghostty/config" "$HOME/.config/ghostty/config"
  [[ "${DOTFILES_ROUTE-}" != "hm" ]] && link "$DOTFILES_DIR/xdg/nano/nanorc" "$HOME/.config/nano/nanorc"

  # Codex config (Codex reads ~/.codex/config.toml)
  link "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml"

  # Dotfiles helper CLI
  install_dot_cli
}

# ----------------------------
# Ollama
# ----------------------------
ensure_ollama_installed() {
  if command_exists ollama; then
    log "Ollama already installed."
    return 0
  fi

  # Homebrew route: install directly (or via Brewfile—see notes below)
  if command_exists brew; then
    log "Installing Ollama via Homebrew..."
    brew install ollama  # brew formula install command (https://formulae.brew.sh/formula/ollama)
    return 0
  fi

  # Nix route: install should come from your Home Manager config
  if command_exists nix; then
    warn "Ollama not found on PATH."
    warn "If you're using --method nix, enable pkgs.ollama in nix/home.nix, then rerun install."
    return 1
  fi

  warn "Neither brew nor nix found; cannot install Ollama automatically."
  return 1
}

# ----------------------------
# Setup paths (brew vs nix)
# ----------------------------
setup_via_homebrew() {
  log "Setup method: Homebrew"
  if [[ "$RUN_BREW" -eq 1 ]]; then
    run_brew_bundle
    ensure_ollama_installed
  else
    log "Skipping Brewfile (run with --brew to install packages)."
  fi

  symlink_dotfiles
}

setup_via_nix_home_manager() {
  log "Setup method: Determinate Nix + Home Manager"

  if is_macos; then
    install_determinate_nix_macos
    install_home_manager_nix_macos
  else
    warn "Nix path not implemented for this OS yet."
    return 0
  fi

  # 3) Run your flake
  # if [[ -z "${DOTFILES_DIR:-}" ]]; then
  #   # If your script already defines DOTFILES_DIR, you can drop this.
  #   DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # fi

  if [[ ! -f "$DOTFILES_DIR/flake.nix" ]]; then
    warn "No flake.nix found at: $DOTFILES_DIR"
    warn "Skipping: home-manager switch --flake .#default --impure"
    return 0
  fi

  log "Activating Home Manager flake: .#default (impure)"
  (
    cd "$DOTFILES_DIR"

    if command_exists home-manager; then
      home-manager --extra-experimental-features "nix-command flakes" \
        switch --flake ".#default" --impure
    else
      warn "home-manager not on PATH yet; using nix run fallback."
      nix_with_flakes run "github:nix-community/home-manager" -- \
        switch --flake ".#default" --impure
    fi
  )

  log "Home Manager activation complete."
  ensure_ollama_installed
}

# ----------------------------
# Main
# ----------------------------
main() {
  log "Dev machine setup"

  if [[ "$ASSUME_YES" -ne 1 ]]; then
    if ! confirm "Would you like to begin the setup?" "Y"; then
      log "Aborted by user."
      exit 0
    fi
  fi

  # Check secrets early (works for both brew + nix routes)
  # Accept either:
  # - a single shared key (openai_api_key), OR
  # - per-tool keys (openai_api_key_llm + openai_api_key_codex)
  if [[ -f "$DOTFILES_DIR/secrets/openai_api_key.example" ]]; then
    ensure_secret_reminder "openai_api_key" "secrets/openai_api_key.example" "OpenAI API key"
  else
    ensure_secret_reminder "openai_api_key_llm"   "secrets/openai_api_key_llm.example"   "OpenAI API key (llm)"
    ensure_secret_reminder "openai_api_key_codex" "secrets/openai_api_key_codex.example" "OpenAI API key (codex)"
  fi

  if is_macos; then
    # Decide method: CLI flag wins, otherwise prompt (default homebrew)
    local method="$METHOD"
    if [[ -z "$method" ]]; then
      method="$(choose "How would you like to set up this machine?" "homebrew" "homebrew" "nix")"
    fi

    case "$method" in
      homebrew) setup_via_homebrew ;;
      nix)      setup_via_nix_home_manager ;;
      *)
        err "Invalid --method '$method' (expected 'homebrew' or 'nix')"
        exit 2
        ;;
    esac

  elif is_linux; then
    warn "Linux detected. Currently only dotfile symlinks run by default."
    # You can extend here later (nix vs distro packages, etc.)
  else
    err "Unsupported OS: $(uname -s)"
    exit 1
  fi

  # Optionally, install any defined Ollama models
  #   init. via `INSTALL_OLLAMA_MODELS=1 OLLAMA_MODELS="qwen3-coder llama3.2" ./install.sh`
  if [[ "${INSTALL_OLLAMA_MODELS:-}" == "1" ]]; then
    # OLLAMA_MODELS="deepseek-r1:14b devstral-2 devstral-small-2 gpt-oss llama3.1:8b qwen3-coder:30b qwen2.5-coder:7b nishtahir/zeta lennyerik/zeta"
    OLLAMA_MODELS="${OLLAMA_MODELS:-gemma3}" ./scripts/ollama-models.sh
  fi

  log "All done."
}

main "$@"

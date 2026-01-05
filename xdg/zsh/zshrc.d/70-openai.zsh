# ------------------------------------------------------------------------------
# OpenAI / AI tooling bootstrap (LLM + Codex)
# Secrets are file-based and intentionally NOT in git.
# Expected secret file: ~/.config/secrets/openai_api_key
# ------------------------------------------------------------------------------

# Generic helper: read a secret from ~/.config/secrets/<file_name>
# and export it to an environment variable.
#
# Usage:
#   ensure_secret openai_api_key OPENAI_API_KEY
#   ensure_secret github_token   GITHUB_TOKEN
ensure_secret() {
  local file_name="$1"
  local env_name="$2"

  local secrets_dir="${XDG_CONFIG_HOME:-$HOME/.config}/secrets"
  local key_file="$secrets_dir/$file_name"

  # Ensure directory exists + is private
  mkdir -p "$secrets_dir" 2>/dev/null || true
  chmod 700 "$secrets_dir" 2>/dev/null || true

  if [[ ! -f "$key_file" ]]; then
    print -P "%F{214}⚠️  Missing secret file:%f $key_file"
    print -P "   Create it (chmod 600) and put the key on a single line."
    return 1
  fi

  # Refuse insecure perms if we can detect them (best-effort).
  # On macOS, `stat -f %Lp`; on Linux, `stat -c %a`.
  local perms=""
  if command -v stat >/dev/null 2>&1; then
    perms="$(stat -f %Lp "$key_file" 2>/dev/null || stat -c %a "$key_file" 2>/dev/null || true)"
  fi
  if [[ -n "$perms" && "$perms" != "600" ]]; then
    print -P "%F{214}⚠️  Secret file permissions should be 600:%f $key_file (currently $perms)"
    print -P "   Fix with: chmod 600 \"$key_file\""
  fi

  # Read first line, trim trailing newline
  local value
  value="$(head -n 1 "$key_file" | tr -d '\r\n')"

  if [[ -z "$value" ]]; then
    print -P "%F{214}⚠️  Secret file is empty:%f $key_file"
    return 1
  fi

  export "$env_name=$value"
  return 0
}

# Load OpenAI key for both llm and codex (common convention).
# ensure_openai_key() {
#   ensure_secret "openai_api_key" "OPENAI_API_KEY"
# }

# Load separate keys
ensure_openai_key_codex() {
  ensure_secret "openai_api_key_codex" "OPENAI_API_KEY_CODEX"
}

ensure_openai_key_llm() {
  ensure_secret "openai_api_key_llm" "OPENAI_API_KEY_LLM"
}

# Run a command with a specific OpenAI key (without permanently changing OPENAI_API_KEY)
with_openai_key() {
  local which="$1"; shift
  local key=""

  case "$which" in
    codex)
      ensure_openai_key_codex >/dev/null 2>&1
      key="${OPENAI_API_KEY_CODEX:-}"
      ;;
    llm)
      ensure_openai_key_llm >/dev/null 2>&1
      key="${OPENAI_API_KEY_LLM:-}"
      ;;
    *)
      print -P "%F{214}✗ with_openai_key: unknown key type%f ($which)"
      return 2
      ;;
  esac

  if [[ -z "$key" ]]; then
    print -P "%F{214}✗ Missing OpenAI key for%f $which"
    return 1
  fi

  OPENAI_API_KEY="$key" "$@"
}

# "ai doctor" sanity check: key + codex provider/model + llm availability
ai() {
  local cmd="${1:-}"
  if [[ "$cmd" == "doctor" ]]; then
    # ensure_openai_key >/dev/null 2>&1
    ensure_openai_key_codex >/dev/null 2>&1
    ensure_openai_key_llm   >/dev/null 2>&1
    # [[ -n "${OPENAI_API_KEY:-}" ]] && print -P "%F{82}✓ OPENAI_API_KEY is set%f" || print -P "%F{214}✗ OPENAI_API_KEY not set%f (expected ~/.config/secrets/openai_api_key)"
    [[ -n "${OPENAI_API_KEY_CODEX:-}" ]] && print -P "%F{82}✓ OPENAI_API_KEY_CODEX is set%f" || print -P "%F{214}✗ OPENAI_API_KEY_CODEX not set%f"
    [[ -n "${OPENAI_API_KEY_LLM:-}"   ]] && print -P "%F{82}✓ OPENAI_API_KEY_LLM is set%f"   || print -P "%F{214}✗ OPENAI_API_KEY_LLM not set%f"

    if command -v llm >/dev/null 2>&1; then
      print -P "%F{82}✓ llm found:%f $(command -v llm)"
      llm --version 2>/dev/null || true
    else
      print -P "%F{214}✗ llm not found%f (install via Homebrew or Nix/Home Manager)"
    fi

    if command -v codex >/dev/null 2>&1; then
      print -P "%F{82}✓ codex found:%f $(command -v codex)"
      # Read model/provider from ~/.codex/config.toml (best-effort grep)
      local cfg="${HOME}/.codex/config.toml"
      if [[ -f "$cfg" ]]; then
        local model provider
        model="$(grep -E '^[[:space:]]*model[[:space:]]*=' "$cfg" | head -n 1 | sed -E 's/.*=[[:space:]]*"([^"]+)".*/\1/')"
        provider="$(grep -E '^[[:space:]]*provider[[:space:]]*=' "$cfg" | head -n 1 | sed -E 's/.*=[[:space:]]*"([^"]+)".*/\1/')"
        [[ -n "$provider" ]] && print -P "  provider: %F{82}$provider%f" || print -P "  provider: (not set in config)"
        [[ -n "$model" ]] && print -P "  model:    %F{82}$model%f" || print -P "  model:    (not set in config)"
      else
        print -P "%F{214}⚠️  ~/.codex/config.toml not found%f (consider symlinking from repo)"
      fi
    else
      print -P "%F{214}✗ codex not found%f (install via Homebrew/Nix or your chosen route)"
    fi
    return 0
  fi

  # Default: print quick help
  print "Usage:"
  print "  ai doctor      # check key + llm + codex + codex config"
}

# Optional convenience wrappers (so they always have the key in scope)
# llm-openai() { ensure_openai_key >/dev/null 2>&1; command llm "$@"; }
# codex-openai() { ensure_openai_key >/dev/null 2>&1; command codex "$@"; }

# Override the commands so they always pick the right key automatically.
# `command codex` / `command llm` ensures we call the real binary.
codex() { with_openai_key codex command codex "$@"; }
llm()   { with_openai_key llm   command llm   "$@"; }

# Optional: ZLE widget to rewrite the current command line using LLM
# Hit ^X^A to transform your current buffer into a command.
autoload -Uz add-zle-hook-widget 2>/dev/null || true

_ai_rewrite_buffer() {
  local prompt="Rewrite this into a correct, safe shell command. Output ONLY the command, no backticks:\n\n$BUFFER"
  local out
  out="$(printf "%s" "$prompt" | llm --no-stream --stdin 2>/dev/null)"
  if [[ -n "$out" ]]; then
    BUFFER="$out"
    CURSOR=${#BUFFER}
  fi
  zle redisplay
}
zle -N _ai_rewrite_buffer
bindkey '^X^A' _ai_rewrite_buffer
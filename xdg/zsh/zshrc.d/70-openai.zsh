# Optional API keys. Normal codex/llm retain their own sign-in.
with_openai_key() {
  local tool="$1" key_file key
  shift
  case "$tool" in
    codex|llm) ;;
    *) print -u2 'Usage: with_openai_key <codex|llm> command [args...]'; return 2 ;;
  esac
  key_file="$XDG_CONFIG_HOME/secrets/openai_api_key_$tool"
  [[ -r "$key_file" ]] || key_file="$XDG_CONFIG_HOME/secrets/openai_api_key"
  [[ -r "$key_file" ]] || { print -u2 "Missing optional API key for $tool"; return 1; }
  IFS= read -r key < "$key_file" || [[ -n "$key" ]] || return 1
  key="${key%$'\r'}"
  [[ -n "$key" ]] || return 1
  OPENAI_API_KEY="$key" "$@"
}
codex-openai() { with_openai_key codex command codex "$@"; }
llm-openai() { with_openai_key llm command llm "$@"; }

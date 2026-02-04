#!/usr/bin/env bash
# 
# # Pull a default (gemma3)
# ./scripts/ollama-models.sh

# # Or specify your own
# OLLAMA_MODELS="qwen3-coder llama3.2" ./scripts/ollama-models.sh
set -euo pipefail

# Space-separated list, e.g.:
#   OLLAMA_MODELS="qwen3-coder llama3.2 gemma3"
# OLLAMA_MODELS="deepseek-r1:14b devstral-2 devstral-small-2 gpt-oss llama3.1:8b qwen3-coder:30b qwen2.5-coder:7b nishtahir/zeta lennyerik/zeta"
MODELS="${OLLAMA_MODELS:-gemma3}"

O_LLAMA_HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1"
    exit 1
  }
}

wait_for_server() {
  local tries=30
  until curl -fsS "$O_LLAMA_HOST/" >/dev/null 2>&1; do
    tries=$((tries-1))
    if [[ $tries -le 0 ]]; then
      echo "Ollama server not responding at $O_LLAMA_HOST"
      exit 1
    fi
    sleep 1
  done
}

ensure_server() {
  if curl -fsS "$O_LLAMA_HOST/" >/dev/null 2>&1; then
    return 0
  fi

  # If installed via Homebrew, prefer launchd service
  if command -v brew >/dev/null 2>&1 && brew list --formula ollama >/dev/null 2>&1; then
    # Homebrew Services manages background services (launchd)
    brew services start ollama >/dev/null 2>&1 || true
  else
    # Fallback: start a user server in the background for this session
    nohup ollama serve >/tmp/ollama-serve.log 2>&1 &
  fi

  wait_for_server
}

main() {
  need_cmd ollama
  need_cmd curl

  ensure_server

  # Build a set of already-installed model names
  mapfile -t installed < <(ollama ls 2>/dev/null | awk 'NR>1 {print $1}' | sort -u)

  for m in $MODELS; do
    if printf '%s\n' "${installed[@]}" | grep -qx "$m"; then
      echo "Already installed: $m"
      continue
    fi

    echo "Pulling: $m"
    ollama pull "$m"
  done

  echo "Done. Installed models:"
  ollama ls
}

main "$@"
#!/usr/bin/env bash
if ! command -v jq >/dev/null 2>&1 || ! command -v nix-prefetch-github >/dev/null 2>&1; then
  exec nix develop -c "$0" "$@"
fi

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_FILE="$REPO_ROOT/nix/pkgs/bbrew.nix"
OWNER="Valkyrie00"
REPO="bold-brew"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    # echo "Missing '$1' on PATH. Run: nix develop"
    echo "Tool missing even inside devShell"
    exit 1
  }
}

need curl
need jq
need nix-prefetch-github
need git
need nix

# 1) Get latest tag (e.g. v2.2.1)
# latest_tag="$(
#   curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/tags?per_page=1" \
#   | jq -r '.[0].name'
# )"

# 1b) Get latest release (e.g. v2.2.1)
latest_release="$(
  curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
  | jq -r .tag_name
)"

if [[ -z "$latest_release" || "$latest_release" == "null" ]]; then
  echo "Failed to detect latest tag"
  exit 1
fi

version="${latest_release#v}"
echo "Latest tag: $latest_release  (version: $version)"

# 2) Prefetch source hash
src_hash="$(
  nix-prefetch-github "${OWNER}" "${REPO}" --rev "${latest_release}" \
  | jq -r .hash
)"

echo "src.hash: $src_hash"

# 3) Patch version + rev + src hash
tmp="$(mktemp)"
# awk -v version="$version" -v tag="$latest_release" -v src_hash="$src_hash" '
#   { line=$0 }
#   $0 ~ /version = "/ {
#     sub(/version = "[^"]+"/, "version = \""version"\"", line)
#   }
#   $0 ~ /rev[[:space:]]*=[[:space:]]*"/ {
#     sub(/rev[[:space:]]*=[[:space:]]*"[^"]+"/, "rev   = \""tag"\"", line)
#   }
#   $0 ~ /hash[[:space:]]*=[[:space:]]*"/ {
#     sub(/hash[[:space:]]*=[[:space:]]*"[^"]+"/, "hash  = \""src_hash"\"", line)
#   }
#   { print line }
# ' "$PKG_FILE" > "$tmp"
awk -v version="$version" -v tag="$latest_release" -v src_hash="$src_hash" '
  { line=$0 }
  $0 ~ /version = "/ {
    sub(/version = "[^"]+"/, "version = \""version"\"", line)
  }
  $0 ~ /hash[[:space:]]*=[[:space:]]*"/ {
    sub(/hash[[:space:]]*=[[:space:]]*"[^"]+"/, "hash  = \""src_hash"\"", line)
  }
  { print line }
' "$PKG_FILE" > "$tmp"
mv "$tmp" "$PKG_FILE"

# If nothing changed, bail early (keeps it quiet)
if git diff --quiet; then
  echo "No changes; exiting."
  exit 0
fi

# 4) Compute vendorHash by triggering buildGoModule hash failure and reading the "got:" line
set +e
build_out="$(cd "$REPO_ROOT" && nix build .#bbrew -L --no-link 2>&1)"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "Build succeeded; vendorHash already correct."
  exit 0
fi

# Prefer the go-modules "got:" line
vendor_hash="$(
  echo "$build_out" \
  | awk '
      /go-modules\.drv/ { inmods=1 }
      inmods && /got: sha256-/ { print $NF; exit }
    '
)"

if [[ -z "$vendor_hash" ]]; then
  echo "Could not extract vendorHash from build output."
  echo "$build_out"
  exit 1
fi

echo "vendorHash: $vendor_hash"

# 5) Patch vendorHash
tmp="$(mktemp)"
awk -v vendor_hash="$vendor_hash" '
  { line=$0 }
  $0 ~ /vendorHash[[:space:]]*=[[:space:]]*"/ {
    sub(/vendorHash[[:space:]]*=[[:space:]]*"[^"]+"/, "vendorHash = \""vendor_hash"\"", line)
  }
  { print line }
' "$PKG_FILE" > "$tmp"
mv "$tmp" "$PKG_FILE"

echo "Updated $PKG_FILE"
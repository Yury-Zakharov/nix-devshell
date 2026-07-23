#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OVERLAY="${REPO_ROOT}/overlays/spec-kit.nix"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

for cmd in curl jq nix-prefetch-url; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: required command not found: $cmd" >&2
    exit 1
  fi
done

if [[ ! -f "$OVERLAY" ]]; then
  echo "error: overlay not found: $OVERLAY" >&2
  exit 1
fi

echo "→ Fetching latest release from github/spec-kit ..."
TAG=$(curl -sL https://api.github.com/repos/github/spec-kit/releases/latest | jq -r .tag_name)

if [[ -z "$TAG" || "$TAG" == "null" ]]; then
  echo "error: failed to obtain latest tag" >&2
  exit 1
fi

VERSION="${TAG#v}"
CURRENT_VERSION=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$OVERLAY" | head -1)

echo "Current: ${CURRENT_VERSION:-?} → Latest: $TAG"

# ------------------------------------------------------------------
# 1. Version / hash
# ------------------------------------------------------------------
NEED_VERSION_UPDATE=0
if [[ "$CURRENT_VERSION" != "$VERSION" ]]; then
  NEED_VERSION_UPDATE=1
  echo "→ Prefetching sha256 for $TAG ..."
  SHA256=$(nix-prefetch-url --unpack "https://github.com/github/spec-kit/archive/refs/tags/${TAG}.tar.gz")
  if [[ -z "$SHA256" ]]; then
    echo "error: failed to obtain sha256" >&2
    exit 1
  fi
  echo "  version  = \"$VERSION\""
  echo "  rev      = \"$TAG\""
  echo "  sha256   = \"$SHA256\""
else
  echo "Version already up to date."
fi

# ------------------------------------------------------------------
# 2. Dependencies (from upstream pyproject.toml)
# ------------------------------------------------------------------
echo "→ Fetching upstream dependencies ..."
PYPROJECT=$(curl -sL "https://raw.githubusercontent.com/github/spec-kit/${TAG}/pyproject.toml")

# Extract the dependencies array (simple TOML list of strings)
UPSTREAM_DEPS=$(echo "$PYPROJECT" \
  | sed -n '/^dependencies = \[/,/^]/p' \
  | grep -oE '"[^"]+"' \
  | sed 's/"//g' \
  | sed 's/[><=].*//' \
  | tr '[:upper:]' '[:lower:]' \
  | sort -u)

if [[ -z "$UPSTREAM_DEPS" ]]; then
  echo "error: could not parse dependencies from pyproject.toml" >&2
  exit 1
fi

echo "Upstream dependencies:"
echo "$UPSTREAM_DEPS" | sed 's/^/  - /'

# Current deps from the overlay (inside the with prev.python3Packages; [ ... ] block)
CURRENT_DEPS=$(sed -n '/propagatedBuildInputs = with prev.python3Packages; \[/,/^\s*\];/p' "$OVERLAY" \
  | grep -oE '[a-zA-Z0-9_-]+' \
  | grep -v -E '^(propagatedBuildInputs|with|prev|python3Packages)$' \
  | sort -u)

echo "Current overlay dependencies:"
echo "$CURRENT_DEPS" | sed 's/^/  - /'

# Diff
MISSING=$(comm -23 <(echo "$UPSTREAM_DEPS") <(echo "$CURRENT_DEPS") || true)
EXTRA=$(comm -13 <(echo "$UPSTREAM_DEPS") <(echo "$CURRENT_DEPS") || true)

NEED_DEPS_UPDATE=0
if [[ -n "$MISSING" || -n "$EXTRA" ]]; then
  NEED_DEPS_UPDATE=1
  echo
  if [[ -n "$MISSING" ]]; then
    echo "Missing in overlay (will be added):"
    echo "$MISSING" | sed 's/^/  + /'
  fi
  if [[ -n "$EXTRA" ]]; then
    echo "Extra in overlay (will be removed):"
    echo "$EXTRA" | sed 's/^/  - /'
  fi
else
  echo "Dependencies already match upstream."
fi

# ------------------------------------------------------------------
# Early exit if nothing to do
# ------------------------------------------------------------------
if [[ $NEED_VERSION_UPDATE -eq 0 && $NEED_DEPS_UPDATE -eq 0 ]]; then
  echo "Nothing to update."
  exit 0
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo
  echo "(dry-run) no changes written"
  exit 0
fi

# ------------------------------------------------------------------
# Apply updates
# ------------------------------------------------------------------
if [[ $NEED_VERSION_UPDATE -eq 1 ]]; then
  sed -i \
    -e "s/version = \"[^\"]*\";/version = \"${VERSION}\";/" \
    -e "s/rev = \"[^\"]*\";/rev = \"${TAG}\";/" \
    -e "s/sha256 = \"[^\"]*\";/sha256 = \"${SHA256}\";/" \
    "$OVERLAY"
  echo "Updated version / rev / sha256"
fi

if [[ $NEED_DEPS_UPDATE -eq 1 ]]; then
  # Build the new list (sorted, one per line, 2-space indent)
  NEW_LIST=$(echo "$UPSTREAM_DEPS" | sed 's/^/    /')

  # Replace the entire propagatedBuildInputs block
  # (matches the common formatting used in the overlay)
  awk -v newlist="$NEW_LIST" '
    BEGIN { in_block=0 }
    /propagatedBuildInputs = with prev.python3Packages; \[/ {
      print "    propagatedBuildInputs = with prev.python3Packages; ["
      print newlist
      print "    ];"
      in_block=1
      next
    }
    in_block && /^\s*\];/ { in_block=0; next }
    !in_block { print }
  ' "$OVERLAY" > "${OVERLAY}.tmp" && mv "${OVERLAY}.tmp" "$OVERLAY"

  echo "Updated propagatedBuildInputs"
fi

echo "Done. Overlay written to $OVERLAY"

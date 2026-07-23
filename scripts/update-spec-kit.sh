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
  echo "error: failed to obtain latest tag." >&2
  exit 1
fi

VERSION="${TAG#v}"

CURRENT_VERSION=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$OVERLAY" | head -1)

if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
  echo "Already at latest: $TAG"
  exit 0
fi

echo "Current: $CURRENT_VERSION → Latest: $TAG"

echo "→ Prefetching sha256 for $TAG ..."
SHA256=$(nix-prefetch-url --unpack "https://github.com/github/spec-kit/archive/refs/tags/${TAG}.tar.gz")

if [[ -z "$SHA256" ]]; then
  echo "error: failed to obtain sha256." >&2
  exit 1
fi

echo "  version  = \"$VERSION\""
echo "  rev      = \"$TAG\""
echo "  sha256   = \"$SHA256\""

if [[ $DRY_RUN -eq 1 ]]; then
  echo "(dry-run) no changes written."
  exit 0
fi

# Update the three fields in place (legacy sha256 format preserved)
sed -i \
  -e "s/version = \"[^\"]*\";/version = \"${VERSION}\";/" \
  -e "s/rev = \"[^\"]*\";/rev = \"${TAG}\";/" \
  -e "s/sha256 = \"[^\"]*\";/sha256 = \"${SHA256}\";/" \
  "$OVERLAY"

echo "Updated $OVERLAY"

#!/usr/bin/env bash
set -euo pipefail

# Single owner: this script.
# Pins overlays/job-radar.nix to origin/main of maccydee/job-radar
# and refreshes the unpacked sha256. No releases are published;
# main is the upstream channel.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OVERLAY="${REPO_ROOT}/overlays/job-radar.nix"

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

echo "→ Fetching HEAD of maccydee/job-radar@main ..."
SHA=$(curl -sL https://api.github.com/repos/maccydee/job-radar/commits/main | jq -r .sha)
DATE=$(curl -sL https://api.github.com/repos/maccydee/job-radar/commits/main | jq -r .commit.committer.date | cut -c1-10)

if [[ -z "$SHA" || "$SHA" == "null" ]]; then
  echo "error: failed to obtain latest commit sha" >&2
  exit 1
fi

PYPROJECT=$(curl -sL "https://raw.githubusercontent.com/maccydee/job-radar/${SHA}/pyproject.toml")
UPSTREAM_VERSION=$(printf '%s\n' "$PYPROJECT" | sed -n 's/^version = "\([^"]*\)".*/\1/p' | head -1)
if [[ -z "$UPSTREAM_VERSION" ]]; then
  UPSTREAM_VERSION="0.1.0"
fi
VERSION="${UPSTREAM_VERSION}-unstable-${DATE}"

CURRENT_REV=$(sed -n 's/.*rev = "\([^"]*\)".*/\1/p' "$OVERLAY" | head -1)
CURRENT_VERSION=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$OVERLAY" | head -1)

echo "Current: ${CURRENT_VERSION:-?} @ ${CURRENT_REV:-?}"
echo "Latest:  $VERSION @ $SHA"

# ------------------------------------------------------------------
# Dependencies (from upstream pyproject.toml)
# ------------------------------------------------------------------
echo "→ Parsing upstream dependencies ..."
UPSTREAM_DEPS=$(printf '%s\n' "$PYPROJECT" \
  | sed -n '/^dependencies = \[/,/^]/p' \
  | grep -oE '"[^"]+"' \
  | sed 's/"//g' \
  | sed 's/[><=].*//' \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's/pyyaml/pyyaml/' \
  | sort -u)

echo "Upstream runtime dependencies:"
echo "$UPSTREAM_DEPS" | sed 's/^/  - /'

# ------------------------------------------------------------------
# Early compare
# ------------------------------------------------------------------
NEED_VERSION_UPDATE=0
if [[ "$CURRENT_REV" != "$SHA" ]]; then
  NEED_VERSION_UPDATE=1
fi

if [[ $NEED_VERSION_UPDATE -eq 0 ]]; then
  echo "Already on latest main. Nothing to prefetch."
  exit 0
fi

echo "→ Prefetching unpacked sha256 for $SHA ..."
SHA256=$(nix-prefetch-url --unpack "https://github.com/maccydee/job-radar/archive/${SHA}.tar.gz")
if [[ -z "$SHA256" ]]; then
  echo "error: failed to obtain sha256" >&2
  exit 1
fi

echo "  version = \"$VERSION\""
echo "  rev     = \"$SHA\""
echo "  sha256  = \"$SHA256\""

if [[ $DRY_RUN -eq 1 ]]; then
  echo
  echo "(dry-run) no changes written"
  exit 0
fi

sed -i \
  -e "s/version = \"[^\"]*\";/version = \"${VERSION}\";/" \
  -e "s/rev = \"[^\"]*\";/rev = \"${SHA}\";/" \
  -e "s/sha256 = \"[^\"]*\";/sha256 = \"${SHA256}\";/" \
  "$OVERLAY"

echo "Done. Overlay written to $OVERLAY"
echo "Reminder: pypdf is kept as an extra even if upstream lists it optional."

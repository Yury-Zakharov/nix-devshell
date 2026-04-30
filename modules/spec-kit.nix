{ pkgs }:

{
  packages = [ pkgs.spec-kit ];

  shellHook = ''
    export SPEC_KIT_HOME="$XDG_CACHE_HOME/spec-kit"
    mkdir -p "$SPEC_KIT_HOME"

    echo "Spec-kit: $(specify version 2>/dev/null || echo "not found")"

    # Pre-configure spec-kit – copy our constitution, overwriting placeholder
    if [ -n "''${SPEC_KIT_HOME:-}" ] && [ -d ".specify" ]; then
      mkdir -p .specify/memory
      chmod -R u+w .specify/memory 2>/dev/null || true
      if [ ! -f ".specify/memory/constitution.md" ] || grep -q "\[PROJECT_NAME\]" ".specify/memory/constitution.md" 2>/dev/null; then
        rm -f .specify/memory/constitution.md
        cp ${./spec-kit/defaults/constitution.md} .specify/memory/constitution.md
        chmod u+w .specify/memory/constitution.md
        echo "✓ spec-kit pre-configured with custom constitution"
      fi
    fi

    # Pre-configure GitHub workflow files (copied only on first run)
    if [ ! -d ".github/workflows" ]; then
      mkdir -p .github/workflows
      cp ${./spec-kit/defaults/.github/workflows/ci.yml} .github/workflows/ci.yml
      chmod u+w .github/workflows/ci.yml
      echo "✓ GitHub CI workflow copied"
    fi

    if [ ! -f ".github/pull_request_template.md" ]; then
      mkdir -p .github
      cp ${./spec-kit/defaults/.github/pull_request_template.md} .github/pull_request_template.md
      chmod u+w .github/pull_request_template.md
      echo "✓ GitHub PR template copied"
    fi
  '';
}

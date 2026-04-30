{ pkgs }:

{
  packages = [ pkgs.spec-kit ];

  shellHook = ''
    export SPEC_KIT_HOME="$XDG_CACHE_HOME/spec-kit"
    mkdir -p "$SPEC_KIT_HOME"

    echo "Spec-kit: $(specify version 2>/dev/null || echo "not found")"

    # Pre-configure spec-kit – force our custom constitution (handles permission issues)
    if [ -n "''${SPEC_KIT_HOME:-}" ] && [ -d ".specify" ]; then
      mkdir -p .specify/memory
      chmod -R u+w .specify/memory 2>/dev/null || true
      if [ ! -f ".specify/memory/constitution.md" ] || grep -q "\[PROJECT_NAME\]" ".specify/memory/constitution.md" 2>/dev/null; then
        rm -f .specify/memory/constitution.md
        cp ${./spec-kit/defaults/constitution.md} .specify/memory/constitution.md
        chmod u+w .specify/memory/constitution.md
        echo "✓ spec-kit pre-configured with custom tech-agnostic constitution"
      fi
    fi
  '';
}

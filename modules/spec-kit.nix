{ pkgs }:

{
  packages = [ pkgs.spec-kit ];

  shellHook = ''
    export SPEC_KIT_HOME="$XDG_CACHE_HOME/spec-kit"
    mkdir -p "$SPEC_KIT_HOME"

    echo "Spec-kit: $(specify version 2>/dev/null || echo "not found")"

    # Pre-configure spec-kit – copy our constitution, overwriting spec-kit's default placeholder
    if [ -n "''${SPEC_KIT_HOME:-}" ] && [ -d ".specify" ]; then
      if [ ! -f ".specify/memory/constitution.md" ] || grep -q "\[PROJECT_NAME\]" ".specify/memory/constitution.md"; then
        cp ${./spec-kit/defaults/constitution.md} .specify/memory/constitution.md
        chmod u+w .specify/memory/constitution.md
        echo "✓ spec-kit pre-configured with custom tech-agnostic constitution"
      fi
    fi
  '';
}

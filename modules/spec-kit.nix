{ pkgs }:

{
  packages = [
    pkgs.spec-kit
  ];

  shellHook = ''
    export SPEC_KIT_HOME="$XDG_CACHE_HOME/spec-kit"
    mkdir -p "$SPEC_KIT_HOME"

    # Pre-configure spec-kit (tech-agnostic defaults) – copied only on first run
    if [ -n "${SPEC_KIT_HOME:-}" ] && [ -d ".specify" ] && [ ! -f ".specify/memory/constitution.md" ]; then
      cp ${./spec-kit/defaults/constitution.md} .specify/memory/constitution.md
      chmod u+w .specify/memory/constitution.md
      echo "✓ spec-kit pre-configured with tech-agnostic constitution"
    fi

    echo "Spec-kit: $(specify version 2>/dev/null || echo "not found")"
  '';
}

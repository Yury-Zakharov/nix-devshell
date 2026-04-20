{ pkgs }:

{
  packages = [
    pkgs.spec-kit
  ];

  shellHook = ''
    export SPEC_KIT_HOME="$XDG_CACHE_HOME/spec-kit"
    mkdir -p "$SPEC_KIT_HOME"

    echo "Spec-kit: $(specify version 2>/dev/null || echo "not found")"
  '';
}

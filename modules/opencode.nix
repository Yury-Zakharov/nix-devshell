{ pkgs }:

{
  packages = [
    pkgs.opencode
  ];

  shellHook = ''
    export OPENCODE_CONFIG_DIR="$XDG_CONFIG_HOME/.opencode"
    mkdir -p "$OPENCODE_CONFIG_DIR"
    echo "Opencode: $(opencode --version 2>/dev/null || true)"
  '';
}

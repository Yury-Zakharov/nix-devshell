{ pkgs }:

{
  packages = [
    pkgs.kilocode-cli
  ];

  env = {
    # Kilo Code CLI respects environment variable overrides for config
    # We redirect as much as possible into XDG dirs
  };

  shellHook = ''
    export KILO_CONFIG_DIR="$XDG_CONFIG_HOME/.kilocode"
    mkdir -p "$KILO_CONFIG_DIR"

    echo "Kilocode CLI: $(kilocode --version 2>/dev/null || true)"
    echo "Kilocode config: redirected to \$XDG_CONFIG_HOME/.kilocode"
  '';
}

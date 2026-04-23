{ pkgs }:

{
  packages = [
    # pkgs.opencode
  ];

  env = {
    # Podman socket (common as requested)
    PODMAN_SOCKET = "$XDG_RUNTIME_DIR/podman/podman.sock";
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
    TESTCONTAINERS_RYUK_DISABLED = "true";
  };

  shellHook = ''
    # XDG (common)
    export XDG_CACHE_HOME="$PWD/.cache"
    export XDG_CONFIG_HOME="$PWD/.config"
    export XDG_DATA_HOME="$PWD/.local/share"
    mkdir -p "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"

    # Opencode config (common)
    # export OPENCODE_CONFIG_DIR="$XDG_CONFIG_HOME/.opencode"
    # mkdir -p "$OPENCODE_CONFIG_DIR"

    # echo "Opencode: $(opencode --version 2>/dev/null || true)"
    echo "✅ Podman socket configured at $PODMAN_SOCKET"
  '';
}

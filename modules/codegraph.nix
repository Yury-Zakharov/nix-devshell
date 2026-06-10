# Single owner: modules/codegraph.nix
# Zero implicit behaviour. No auto install, no auto index.

{ pkgs }:

{
  packages = [ pkgs.codegraph ];

  shellHook = ''
    mkdir -p "$PWD/.codegraph"

    if command -v opencode >/dev/null 2>&1 && [ ! -f "$PWD/.codegraph/.mcp-configured" ]; then
      echo "→ One-time: run 'codegraph install --location=local --target=opencode --yes' to wire MCP into this opencode"
    fi

    echo "codegraph ready (init -i | status | explore)"
  '';
}

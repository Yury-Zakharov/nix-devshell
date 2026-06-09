# Single owner: modules/codegraph.nix
# Zero implicit behaviour: mkdir only; one-time MCP config only if opencode present + marker absent.
# No auto-index (user runs `codegraph init -i` explicitly when ready). Project root only.

{ pkgs }:

{
  packages = [
    pkgs.codegraph
  ];

  shellHook = ''
    mkdir -p "$PWD/.codegraph"

    # One-time, explicit, project-local MCP wiring for opencode (if both modules loaded)
    if command -v opencode >/dev/null 2>&1; then
      if [ ! -f "$PWD/.codegraph/.mcp-configured" ]; then
        echo "→ Configuring CodeGraph MCP for this project's opencode (local only)..."
        if codegraph install --location=local --target=opencode --yes; then
          touch "$PWD/.codegraph/.mcp-configured"
          echo "✅ CodeGraph MCP configured. (opencode will spawn 'codegraph serve --mcp' on demand)"
        else
          echo "⚠️  Auto-config failed. Run manually once: codegraph install --location=local --target=opencode --yes"
        fi
      fi
    fi

    echo "codegraph: ready (init/index with: codegraph init -i | query: codegraph explore \"...\" | status: codegraph status)"
  '';
}

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

    # One-time hint only (no auto-execution of codegraph install — zero implicit behaviour).
    # Run manually when you want MCP wiring in opencode: codegraph install --location=local --target=opencode --yes
    if command -v opencode >/dev/null 2>&1 && [ ! -f "$PWD/.codegraph/.mcp-configured" ]; then
      echo "→ One-time: run 'codegraph install --location=local --target=opencode --yes' to wire CodeGraph MCP into this project's opencode config."
    fi

    echo "codegraph: ready (init/index with: codegraph init -i | query: codegraph explore \"...\" | status: codegraph status)"
  '';
}

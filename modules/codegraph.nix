{ pkgs }:

let
  nodejs = pkgs.nodejs_24;   # change to pkgs.nodejs if you prefer

  codegraph = pkgs.writeShellScriptBin "codegraph" ''
    set -euo pipefail

    CLI_DIR="$PWD/.codegraph/cli"
    mkdir -p "$CLI_DIR"

    if [ ! -d "$CLI_DIR/node_modules" ]; then
      echo "→ Installing @colbymchenry/codegraph@0.9.9 into $CLI_DIR (first run)..."
      cd "$CLI_DIR"
      ${nodejs}/bin/npm install --no-save --ignore-scripts @colbymchenry/codegraph@0.9.9
      cd - >/dev/null
    fi

    exec ${nodejs}/bin/npx --yes --prefix "$CLI_DIR" @colbymchenry/codegraph "$@"
  '';
in
{
  packages = [ codegraph ];

  shellHook = ''
    mkdir -p "$PWD/.codegraph"

    if command -v opencode >/dev/null 2>&1 && [ ! -f "$PWD/.codegraph/.mcp-configured" ]; then
      echo "→ One-time: run 'codegraph install --location=local --target=opencode --yes' to wire CodeGraph MCP into this project's opencode config."
    fi

    echo "codegraph ready (init -i | status | explore)"
  '';
}

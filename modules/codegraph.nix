{ pkgs }:

let
  nodejs = pkgs.nodejs_24;

codegraph = pkgs.writeShellScriptBin "codegraph" ''
  set -euo pipefail

  CLI_DIR="$PWD/.codegraph/cli"
  mkdir -p "$CLI_DIR"

  # Install native package first
  if [ ! -d "$CLI_DIR/node_modules/@colbymchenry/codegraph-linux-x64" ]; then
    echo "→ Installing native package @colbymchenry/codegraph-linux-x64@0.9.9..."
    cd "$CLI_DIR"
    ${nodejs}/bin/npm install --no-save @colbymchenry/codegraph-linux-x64@0.9.9
    cd - >/dev/null
  fi

  # Install main package if missing
  if [ ! -d "$CLI_DIR/node_modules/@colbymchenry/codegraph" ]; then
    echo "→ Installing @colbymchenry/codegraph@0.9.9..."
    cd "$CLI_DIR"
    ${nodejs}/bin/npm install --no-save --ignore-scripts @colbymchenry/codegraph@0.9.9
    cd - >/dev/null
  fi

  # Directly execute the shim (avoids recursion)
  exec ${nodejs}/bin/node "$CLI_DIR/node_modules/@colbymchenry/codegraph/npm-shim.js" "$@"
'';

in
{
  packages = [ codegraph ];

  shellHook = ''
    mkdir -p "$PWD/.codegraph"

    # One-time hint only (no auto-execution of codegraph install)
    if command -v opencode >/dev/null 2>&1 && [ ! -f "$PWD/.codegraph/.mcp-configured" ]; then
      echo "→ One-time: run 'codegraph install --location=local --target=opencode --yes' to wire CodeGraph MCP into this project's opencode config."
    fi

    echo "codegraph ready (init -i | status | explore)"
  '';
}

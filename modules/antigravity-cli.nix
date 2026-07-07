{ pkgs }:

{
  packages = [
    pkgs.antigravity-cli
  ];

  shellHook = ''
    # Isolation note (research result):
    # antigravity-cli (agy) hardcodes ~/.gemini/antigravity-cli/ for
    # settings.json, keybindings.json, mcp_config.json and plugins/.
    # It does NOT respect XDG_* or any AGY_* env var, and project-local
    # attempts are ignored for MCP servers etc.
    # Full project-root isolation is NOT possible without upstream changes
    # or heavy wrappers (e.g. bwrap --bind). We only ensure the path exists
    # under the project's .config so state stays as contained as upstream allows.

    mkdir -p "$XDG_CONFIG_HOME/.gemini/antigravity-cli"

    echo "antigravity-cli ready: $(agy --version 2>/dev/null || true)"
    echo "   State lives under $XDG_CONFIG_HOME/.gemini/antigravity-cli (project .config)"
    echo "   WARNING: full isolation not supported by upstream (hardcoded $HOME path)"
  '';
}

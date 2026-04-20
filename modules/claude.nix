{ pkgs }:

{
  packages = [
    pkgs.claude-code
  ];

  env = {
    CLAUDE_CONFIG_DIR = "$XDG_CONFIG_HOME/.claude";
  };

  shellHook = ''
    mkdir -p "$CLAUDE_CONFIG_DIR"
    echo "Claude: $(claude --version 2>/dev/null || true)"
    echo "Claude config: fully redirected to \$XDG_CONFIG_HOME/.claude"
  '';
}

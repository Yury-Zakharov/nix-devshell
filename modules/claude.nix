{ pkgs }:

{
  packages = [ pkgs.claude-code ];
  env = { };

  shellHook = ''
    export CLAUDE_CONFIG_DIR="''${CLAUDE_CONFIG_DIR:-$XDG_CONFIG_HOME/claude}"
    mkdir -p "$CLAUDE_CONFIG_DIR/skills"
    echo "Claude config: $CLAUDE_CONFIG_DIR"
  '';
}

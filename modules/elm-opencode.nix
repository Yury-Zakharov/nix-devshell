{ pkgs }:

{
  shellHook = ''
    # Only loaded when you explicitly want OpenCode + Elm support
    echo "→ OpenCode Elm integration enabled (skills + LSP)"

    # Skills are copied from the central skills directory
    SKILLS_DIR="$OPENCODE_CONFIG_DIR/skills"
    mkdir -p "$SKILLS_DIR"
    cp -r ${./opencode-skills/elm}/* "$SKILLS_DIR/" 2>/dev/null || true

    echo "Elm skills loaded into .opencode/skills/"
    echo "OpenCode will now use elm-language-server + Qwen for Elm projects"
  '';
}

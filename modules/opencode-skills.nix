{ pkgs }:

{
  shellHook = ''
    SKILLS_DIR="$OPENCODE_CONFIG_DIR/skills"
    mkdir -p "$SKILLS_DIR/roles"

    # Copy all declarative skills and roles
    cp -r ${./opencode-skills}/* "$SKILLS_DIR/" 2>/dev/null || true

    echo "OpenCode skills + roles loaded into .opencode/skills/"
  '';
}

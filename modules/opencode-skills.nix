{ pkgs }:

{
  shellHook = ''
    SKILLS_DIR="$OPENCODE_CONFIG_DIR/skills"
    mkdir -p "$SKILLS_DIR"

    # Declarative skills from nix-devshell repo (single source of truth)
    cp -r ${./opencode-skills}/* "$SKILLS_DIR/" 2>/dev/null || true

    echo "OpenCode skills loaded from nix-devshell/modules/opencode-skills/"
  '';
}

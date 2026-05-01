{ pkgs }:

{
  packages = [
    pkgs.opencode
    pkgs.nodejs
    pkgs.bun
  ];

  env = {
    OPENCODE_CONFIG_DIR = "$PWD/.opencode";
    OPENCODE_CACHE_DIR  = "$PWD/.opencode/cache";
  };

  shellHook = ''
    mkdir -p "$OPENCODE_CONFIG_DIR" "$OPENCODE_CONFIG_DIR/skills"

    # Install btca locally (project-isolated) to silence micode warning
    export BUN_INSTALL="$OPENCODE_CACHE_DIR/.bun"
    if [ ! -f "$BUN_INSTALL/bin/btca" ]; then
      echo "→ Installing btca for micode plugin (one-time)..."
      mkdir -p "$BUN_INSTALL"
      bun add -g btca
    fi
    export PATH="$BUN_INSTALL/bin:$PATH"

    # Copy default config if it doesn't exist yet (single declaration site)
    if [ ! -f "$OPENCODE_CONFIG_DIR/opencode-reference.md" ]; then
      cp ${./opencode/opencode-reference.md} "$OPENCODE_CONFIG_DIR/opencode-reference.md"
      chmod u+w "$OPENCODE_CONFIG_DIR/opencode-reference.md"
      echo "✓ Copied opencode-reference.md from modules/opencode/opencode-reference.md"
    fi

    # Copy default config if it doesn't exist yet (single declaration site)
    if [ ! -f "$OPENCODE_CONFIG_DIR/opencode.jsonc" ]; then
      cp ${./opencode/default.jsonc} "$OPENCODE_CONFIG_DIR/opencode.jsonc"
      chmod u+w "$OPENCODE_CONFIG_DIR/opencode.jsonc"
      echo "✅ Copied default opencode.jsonc from modules/opencode/default.jsonc"
    fi

    # plugin configs – copied only on first run (zero implicit, single declaration site)
    if [ ! -f "$OPENCODE_CONFIG_DIR/oh-my-openagent.jsonc" ]; then
    cp ${./opencode/default-oh-my-openagent.jsonc} "$OPENCODE_CONFIG_DIR/oh-my-openagent.jsonc"
    chmod u+w "$OPENCODE_CONFIG_DIR/oh-my-openagent.jsonc"
    echo "Copied default oh-my-openagent.jsonc"
    fi

    if [ ! -f "$OPENCODE_CONFIG_DIR/micode.json" ]; then
    cp ${./opencode/default-micode.json} "$OPENCODE_CONFIG_DIR/micode.json"
    chmod u+w "$OPENCODE_CONFIG_DIR/micode.json"
    echo "Copied default micode.json"
    fi

    # spec-kit official OpenCode integration – automatic one-time init
    # runs only when spec-kit module is also loaded + .specify/ missing
    if command -v specify >/dev/null 2>&1 && [ ! -d ".specify" ]; then
    echo "→ Detected spec-kit module. Auto-initializing OpenCode integration..."
    if specify init . --integration opencode --force --script sh; then
        echo "✓ spec-kit initialized with OpenCode integration (.specify/ created)"
        echo "   /speckit.* commands should now be available in OpenCode TUI"
      else
        echo "⚠ spec-kit init failed – run manually: specify init . --integration opencode"
      fi
    fi
    opencode plugin install --yes 2>/dev/null || true
    echo "OpenCode ready"
  '';
}

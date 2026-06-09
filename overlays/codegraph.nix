# Single owner: overlays/codegraph.nix
# Zero implicit behaviour: CLI install happens once, explicitly, into $PWD/.codegraph/cli/
# Index data stays in $PWD/.codegraph/ (tool default). No global state, no ~/

final: prev:

{
  codegraph = let
    nodejs = prev.nodejs_24;
  in prev.stdenvNoCC.mkDerivation {
    pname = "codegraph";
    version = "0.9.9";

    dontUnpack = true;

    nativeBuildInputs = [ nodejs ];

    buildPhase = ''
      mkdir -p $out/bin

      cat > $out/bin/codegraph <<'EOF2'
      #!${prev.runtimeShell}
      export PATH="${nodejs}/bin:${prev.coreutils}/bin:$PATH"

      # Single owner: overlays/codegraph.nix
      # Everything (cli cache + index) lives inside project root/.codegraph/
      CLI_DIR="$PWD/.codegraph/cli"
      mkdir -p "$CLI_DIR"

      cd "$CLI_DIR"
      if [ ! -d "node_modules" ]; then
        echo "→ Installing @colbymchenry/codegraph@0.9.9 into $CLI_DIR (first run only)..."
        ${nodejs}/bin/npm install --no-save --ignore-scripts @colbymchenry/codegraph@0.9.9
      fi

      # Return to original PWD for correct .codegraph/ resolution
      cd "$OLDPWD" 2>/dev/null || true

      exec ${nodejs}/bin/npx --yes --prefix "$CLI_DIR" @colbymchenry/codegraph "$@"
EOF2

      chmod +x $out/bin/codegraph
    '';

    dontInstall = true;
    dontFixup = true;

    meta = with prev.lib; {
      description = "CodeGraph — Pre-indexed local code knowledge graph + MCP server for opencode, Claude, Cursor, dotnet etc.";
      homepage = "https://github.com/colbymchenry/codegraph";
      license = licenses.mit;
      mainProgram = "codegraph";
      platforms = platforms.unix;
    };
  };
}

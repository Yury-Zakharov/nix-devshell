final: prev:

{
  swarmvault = let
    nodejs = prev.nodejs_24;
  in prev.stdenvNoCC.mkDerivation {
    pname = "swarmvault";
    version = "latest";

    dontUnpack = true;

    nativeBuildInputs = [ nodejs ];

    buildPhase = ''
      mkdir -p $out/bin

      cat > $out/bin/swarmvault <<'EOF'
      #!${prev.runtimeShell}
      export PATH="${nodejs}/bin:${prev.coreutils}/bin:$PATH"

      # Single owner: overlays/swarmvault.nix
      # Everything lives in project root/.swarmvault (node_modules + built CLI)
      export SWARMVAULT_ROOT="$PWD/.swarmvault"
      mkdir -p "$SWARMVAULT_ROOT"

      cd "$SWARMVAULT_ROOT"
      if [ ! -d "node_modules" ]; then
        echo "Installing @swarmvaultai/cli@latest into $SWARMVAULT_ROOT (first run only)..."
        ${nodejs}/bin/npm install --no-save --ignore-scripts @swarmvaultai/cli@latest
      fi

      # Run from original project root (so init/ingest create files here)
      cd "$OLDPWD" 2>/dev/null || true

      # Correct entry point (ESM + dist/index.js from package)
      exec ${nodejs}/bin/node \
        "$SWARMVAULT_ROOT/node_modules/@swarmvaultai/cli/dist/index.js" \
        "$@"
      EOF

      chmod +x $out/bin/swarmvault
    '';

    dontInstall = true;
    dontFixup = true;

    meta = with prev.lib; {
      description = "Local-first LLM knowledge base compiler + MCP server";
      homepage = "https://github.com/swarmclawai/swarmvault";
      license = licenses.mit;
      mainProgram = "swarmvault";
      platforms = platforms.unix;
    };
  };
}

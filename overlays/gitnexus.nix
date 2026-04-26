final: prev:

{
  gitnexus = let
    nodejs = prev.nodejs_24;
  in prev.stdenvNoCC.mkDerivation {
    pname = "gitnexus";
    version = "latest";

    dontUnpack = true;

    nativeBuildInputs = [ nodejs ];

    buildPhase = ''
      mkdir -p $out/bin

      cat > $out/bin/gitnexus <<'EOF2'
      #!${prev.runtimeShell}
      export PATH="${nodejs}/bin:${prev.coreutils}/bin:$PATH"

      # Single owner: overlays/gitnexus.nix
      # Everything (graph, indexes, registry, MCP data) lives inside project root/.gitnexus/
      export GITNEXUS_ROOT="$PWD/.gitnexus"
      mkdir -p "$GITNEXUS_ROOT/cli"

      cd "$GITNEXUS_ROOT/cli"
      if [ ! -d "node_modules" ]; then
        echo "Installing gitnexus@latest into $GITNEXUS_ROOT/cli (first run only)..."
        ${nodejs}/bin/npm install --no-save --ignore-scripts gitnexus@latest
      fi

      # Run from original project root
      cd "$OLDPWD" 2>/dev/null || true

      exec ${nodejs}/bin/npx --yes --prefix "$GITNEXUS_ROOT/cli" gitnexus "$@"
EOF2

      chmod +x $out/bin/gitnexus
    '';

    dontInstall = true;
    dontFixup = true;

    meta = with prev.lib; {
      description = "GitNexus — Graph-powered code intelligence for AI agents (latest version)";
      homepage = "https://github.com/abhigyanpatwari/GitNexus";
      license = licenses.mit;
      mainProgram = "gitnexus";
      platforms = platforms.unix;
    };
  };
}

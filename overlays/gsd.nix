final: prev:

{
  gsd = let
    nodejs = prev.nodejs_24;
  in prev.stdenvNoCC.mkDerivation {
    pname = "gsd";
    version = "latest";

    dontUnpack = true;

    nativeBuildInputs = [ nodejs ];

    buildPhase = ''
      mkdir -p $out/bin

      cat > $out/bin/gsd <<'EOF2'
      #!${prev.runtimeShell}
      export PATH="${nodejs}/bin:${prev.coreutils}/bin:$PATH"

      # Single owner: overlays/gsd.nix
      # Everything lives inside project root/.gsd/ (state + node_modules)
      export GSD_ROOT="$PWD/.gsd"
      mkdir -p "$GSD_ROOT/cli"

      cd "$GSD_ROOT/cli"
      if [ ! -d "node_modules" ]; then
        echo "Installing gsd-pi@latest into $GSD_ROOT/cli (first run only)..."
        ${nodejs}/bin/npm install --no-save --ignore-scripts gsd-pi@latest
      fi

      # Run from original project root (so .gsd/ state stays in project)
      cd "$OLDPWD" 2>/dev/null || true

      exec ${nodejs}/bin/node \
        "$GSD_ROOT/cli/node_modules/gsd-pi/dist/cli.js" \
        "$@"
EOF2

      chmod +x $out/bin/gsd
    '';

    dontInstall = true;
    dontFixup = true;

    meta = with prev.lib; {
      description = "GSD 2 — standalone coding agent (latest version)";
      homepage = "https://github.com/gsd-build/gsd-2";
      license = licenses.mit;
      mainProgram = "gsd";
      platforms = platforms.unix;
    };
  };
}

final: prev:

{
  bmad-method = let
    nodejs = prev.nodejs_24;
  in prev.stdenvNoCC.mkDerivation {
    pname = "bmad-method";
    version = "latest";

    dontUnpack = true;

    nativeBuildInputs = [ nodejs ];

    buildPhase = ''
      mkdir -p $out/bin

      cat > $out/bin/bmad-method <<'EOF2'
      #!${prev.runtimeShell}
      export PATH="${nodejs}/bin:${prev.coreutils}/bin:$PATH"

      # Single owner: overlays/bmad-method.nix
      # Everything (CLI + installed modules + state) lives inside project root/.bmad/
      export BMAD_ROOT="$PWD/.bmad"
      mkdir -p "$BMAD_ROOT/cli"

      cd "$BMAD_ROOT/cli"
      if [ ! -d "node_modules" ]; then
        echo "Installing bmad-method@latest into $BMAD_ROOT/cli (first run only)..."
        ${nodejs}/bin/npm install --no-save --ignore-scripts bmad-method@latest
      fi

      # Run from original project root
      cd "$OLDPWD" 2>/dev/null || true

      exec ${nodejs}/bin/node \
        "$BMAD_ROOT/cli/node_modules/bmad-method/tools/installer/bmad-cli.js" \
        "$@"
EOF2

      chmod +x $out/bin/bmad-method

      # Also provide the common alias bmad-help (created after first install)
      ln -s bmad-method $out/bin/bmad-help 2>/dev/null || true
    '';

    dontInstall = true;
    dontFixup = true;

    meta = with prev.lib; {
      description = "BMAD-METHOD — Breakthrough Method for Agile AI Driven Development (latest version)";
      homepage = "https://github.com/bmad-code-org/BMAD-METHOD";
      license = licenses.mit;
      mainProgram = "bmad-method";
      platforms = platforms.unix;
    };
  };
}

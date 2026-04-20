final: prev:

{
  get-shit-done = prev.stdenvNoCC.mkDerivation {
    pname = "get-shit-done";
    version = "1.32.0";

    src = prev.fetchFromGitHub {
      owner = "gsd-build";
      repo = "get-shit-done";
      rev = "v1.33.0";
      sha256 = "1jvspb6qzjz9yq5mvrlyldfms13sc6f7m9mi7lhds9d428g3b1fm";
    };

    nativeBuildInputs = with prev; [ nodejs ];

    buildPhase = ''
      mkdir -p $out/bin

      cat > $out/bin/gsd <<'EOF'
      #!${prev.runtimeShell}
      export PATH="${prev.nodejs}/bin:$PATH"

      # Single owner: this wrapper
      # All state lives inside XDG dirs controlled by base.nix
      export GSD_CACHE_DIR="$XDG_CACHE_HOME/get-shit-done"
      export GSD_DATA_DIR="$XDG_DATA_HOME/get-shit-done"

      mkdir -p "$GSD_CACHE_DIR" "$GSD_DATA_DIR"

      # Run from local cache or install explicitly into project-controlled dir
      cd "$GSD_CACHE_DIR"
      if [ ! -d "node_modules" ]; then
        echo "Installing get-shit-done-cc@1.32.0 into $GSD_CACHE_DIR (first run only)..."
        ${prev.nodejs}/bin/npm install --no-save get-shit-done-cc@1.32.0
      fi

      exec ${prev.nodejs}/bin/npx --yes --prefix "$GSD_CACHE_DIR" get-shit-done-cc@1.32.0 "$@"
      EOF

      chmod +x $out/bin/gsd
    '';

    dontInstall = true;
    dontFixup = true;

    meta = with prev.lib; {
      description = "Light-weight meta-prompting, context engineering and spec-driven development system";
      homepage = "https://github.com/gsd-build/get-shit-done";
      license = licenses.mit;
      mainProgram = "gsd";
      platforms = platforms.unix;
    };
  };
}

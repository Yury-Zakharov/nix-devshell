codegraph = pkgs.stdenvNoCC.mkDerivation {
  pname = "codegraph";
  version = "0.9.9";

  src = pkgs.fetchurl {
    url = "https://github.com/colbymchenry/codegraph/releases/download/v0.9.9/codegraph-linux-x64.tar.gz";
    sha256 = "1ysricisgn3gsdr46043y1nb8718jvlyrrgg9f3lqd9drq5yh3n4";
  };

  nativeBuildInputs = [ pkgs.patchelf ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    tar -xzf $src -C $out --strip-components=1

    # Create the wrapper
    cat > $out/bin/codegraph << 'EOF'
#!/usr/bin/env bash
exec "$out/node" "$out/lib/main.js" "$@"
EOF
    chmod +x $out/bin/codegraph
    runHook postInstall
  '';

  postFixup = ''
    # Patch the bundled node binary for NixOS
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
             --set-rpath "${pkgs.stdenv.cc.cc.lib}/lib" \
             $out/node
  '';

  meta = with pkgs.lib; {
    description = "CodeGraph — Pre-indexed local code knowledge graph + MCP server";
    homepage = "https://github.com/colbymchenry/codegraph";
    license = licenses.mit;
    mainProgram = "codegraph";
    platforms = [ "x86_64-linux" ];
  };
};

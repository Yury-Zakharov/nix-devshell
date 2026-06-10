# Single owner: overlays/codegraph.nix
# Zero implicit behaviour: uses the official self-contained pre-built binary
# from GitHub releases (bundled runtime + tree-sitter). No npm, no node_modules.

final: prev:

let
  version = "0.9.9";
in
{
  codegraph = prev.stdenvNoCC.mkDerivation {
    pname = "codegraph";
    inherit version;

    src = prev.fetchurl {
      url = "https://github.com/colbymchenry/codegraph/releases/download/v${version}/codegraph-linux-x64.tar.gz";
      # Get the real hash once:
      #   nix-prefetch-url https://github.com/colbymchenry/codegraph/releases/download/v0.9.9/codegraph-linux-x64.tar.gz
      hash = "sha256-1ysricisgn3gsdr46043y1nb8718jvlyrrgg9f3lqd9drq5yh3n4="; # ← replace this line
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      tar -xzf $src -C $out/bin --strip-components=1
      chmod +x $out/bin/codegraph || true
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "CodeGraph — Pre-indexed local code knowledge graph + MCP server (official self-contained binary)";
      homepage = "https://github.com/colbymchenry/codegraph";
      license = licenses.mit;
      mainProgram = "codegraph";
      platforms = [ "x86_64-linux" ];
    };
  };
}

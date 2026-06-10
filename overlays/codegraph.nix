final: prev:

let
  version = "0.9.9-working";
in
{
  codegraph = prev.stdenvNoCC.mkDerivation {
    pname = "codegraph";
    inherit version;

    src = prev.fetchurl {
      url = "https://github.com/colbymchenry/codegraph/releases/download/v0.9.9/codegraph-linux-x64.tar.gz";
      hash = "sha256-1ysricisgn3gsdr46043y1nb8718jvlyrrgg9f3lqd9drq5yh3n4=";
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

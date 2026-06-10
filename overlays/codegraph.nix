final: prev:

let
  version = "0.9.9";
in
{
  codegraph = prev.stdenvNoCC.mkDerivation {
    pname = "codegraph";
    inherit version;

    src = builtins.fetchTarball {
      url = "https://github.com/colbymchenry/codegraph/releases/download/v${version}/codegraph-linux-x64.tar.gz";
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

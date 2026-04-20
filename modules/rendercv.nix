{ pkgs }:

{
  packages = [
    pkgs.rendercv
    pkgs.yq
  ];

  env = {
  };

  shellHook = ''
    echo "✅ RenderCV dev environment ready"
    echo "RenderCV: $(rendercv --version 2>/dev/null || true)"
    echo "Run: rendercv render cv.yaml"
  '';
}

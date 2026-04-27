{ pkgs }:

{
  # Avalonia desktop runtime dependencies (SkiaSharp + font rendering)
  packages = [
    pkgs.fontconfig
    pkgs.freetype
    pkgs.libGL
    pkgs.xorg.libX11
    pkgs.xorg.libXrandr
    pkgs.xorg.libXi
    pkgs.xorg.libXcursor
    pkgs.xorg.libXrender
    pkgs.expat
    pkgs.libuuid
  ];

  shellHook = ''
    echo "✅ Avalonia desktop runtime ready (SkiaSharp + native libs)"
    echo "   This module should only be used in Avalonia projects"
    echo "   Combined with devshell.modules.dotnet"
  '';
}

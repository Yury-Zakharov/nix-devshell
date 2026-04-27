{ pkgs }:

{
  # Avalonia desktop runtime dependencies (SkiaSharp + X11)
  # Only enable this module in Avalonia projects
  packages = [
    pkgs.fontconfig
    pkgs.freetype
    pkgs.libGL
    pkgs.libx11
    pkgs.libxrandr
    pkgs.libxi
    pkgs.libxcursor
    pkgs.libxrender
    pkgs.expat
    pkgs.libuuid
    pkgs.mesa

    # These two were missing
    pkgs.libice
    pkgs.libsm
  ];

  shellHook = ''
    # Set LD_LIBRARY_PATH so SkiaSharp / Avalonia can find native libs at runtime
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
      pkgs.fontconfig
      pkgs.freetype
      pkgs.libGL
      pkgs.libx11
      pkgs.libxrandr
      pkgs.libxi
      pkgs.libxcursor
      pkgs.libxrender
      pkgs.expat
      pkgs.libuuid
      pkgs.mesa
      pkgs.libice
      pkgs.libsm
    ]}:$LD_LIBRARY_PATH"

    echo "✅ Avalonia desktop runtime ready"
    echo "   (SkiaSharp, fontconfig, X11, ICE/SM libraries provided)"
    echo "   Use only together with devshell.modules.dotnet"
  '';
}

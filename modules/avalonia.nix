{ pkgs }:

{
  # Avalonia desktop runtime dependencies (SkiaSharp + native libs)
  # Only for experimental Avalonia projects
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
  ];

  shellHook = ''
    # Make SkiaSharp find native libraries at runtime (dotnet run)
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
    ]}:$LD_LIBRARY_PATH"

    echo "✅ Avalonia desktop runtime ready"
    echo "   (SkiaSharp + fontconfig + X11 libs are now available)"
    echo "   Use only in Avalonia projects together with devshell.modules.dotnet"
  '';
}

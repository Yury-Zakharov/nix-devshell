{ pkgs }:

{
  packages = [
    pkgs.SDL2
    pkgs.SDL2_ttf
    pkgs.SDL2_image
    pkgs.libGL
    pkgs.pkg-config

    # X11/Wayland support (required for SDL2 on NixOS desktop)
    pkgs.xorg.libX11
    pkgs.xorg.libXrandr
    pkgs.xorg.libXi
    pkgs.xorg.libXcursor
    pkgs.libxkbcommon
    pkgs.wayland
  ];

  shellHook = ''
    echo "✅ Monomer (Haskell GUI) ready"
    echo "   Add 'monomer' to stack.yaml (extra-deps or resolver)"
    echo "   Use with haskell module"
  '';
}

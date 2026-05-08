{ pkgs }:

{
  packages = [
    pkgs.libsForQt5.qtbase
    pkgs.libsForQt5.qtdeclarative
    pkgs.libsForQt5.qtsvg
    pkgs.libsForQt5.qtwayland
    pkgs.pkg-config

    # Platform / rendering support (required on NixOS)
    pkgs.libGL
    pkgs.xorg.libX11
    pkgs.xorg.libXrandr
    pkgs.xorg.libXi
    pkgs.xorg.libXcursor
    pkgs.libxkbcommon
    pkgs.wayland
  ];

  shellHook = ''
    echo "✅ HsQML (Haskell + Qt Quick/QML) ready"
    echo "   Add 'hsqml' to stack.yaml extra-deps"
    echo "   UI markup in .qml files, logic in Haskell"
  '';
}

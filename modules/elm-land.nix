{ pkgs }:

{
  packages = [
    pkgs.elm-land
  ];

  shellHook = ''
    echo "Elm Land: $(elm-land --version 2>/dev/null || true)"
    echo "Elm Land: project-local by design (no global state)"
  '';
}


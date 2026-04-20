{ pkgs }:

{
  packages = [
    pkgs.elmPackages.elm-spa
  ];

  shellHook = ''
    echo "Elm SPA: $(elm-spa --version 2>/dev/null || true)"
    echo "Elm SPA: project-local by design (no global state)"
  '';
}

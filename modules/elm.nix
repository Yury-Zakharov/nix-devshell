{ pkgs }:

{
  packages = [
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-format
    pkgs.elmPackages.elm-test
    pkgs.elm-land
    pkgs.elmPackages.elm-spa
    pkgs.elmPackages.elm-language-server   # ← added for OpenCode
  ];

  env = {
    ELM_HOME = "$XDG_CACHE_HOME/elm";   # redirected by base.nix to $PWD/.cache
  };

  shellHook = ''
    mkdir -p "$XDG_CACHE_HOME/elm"

    echo "Elm toolchain ready (including elm-language-server for OpenCode)"
    echo "   ELM_HOME → $XDG_CACHE_HOME/elm (project root)"
  '';
}

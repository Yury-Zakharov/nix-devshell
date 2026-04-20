{ pkgs }:

{
  packages = [
    pkgs.elmPackages.elm          # Core Elm compiler
    pkgs.elmPackages.elm-format   # Official formatter
    pkgs.elmPackages.elm-test     # Testing framework
    pkgs.elm-land                 # Elm Land framework
    pkgs.elmPackages.elm-spa      # Elm SPA generator
  ];

  env = {
    # Force Elm tooling to respect XDG directories where possible
    ELM_HOME = "$XDG_CACHE_HOME/elm";
  };

  shellHook = ''
    # Ensure Elm cache lives inside the project-controlled XDG cache
    mkdir -p "$XDG_CACHE_HOME/elm"

    echo "Elm: $(elm --version 2>/dev/null || true)"
    echo "Elm-format: $(elm-format --version 2>/dev/null || true)"
    echo "Elm-test: $(elm-test --version 2>/dev/null || true)"
    echo "Elm Land: $(elm-land --version 2>/dev/null || true)"
    echo "Elm SPA: $(elm-spa --version 2>/dev/null || true)"
    echo "Elm isolation: ELM_HOME redirected to \$XDG_CACHE_HOME/elm"
  '';
}

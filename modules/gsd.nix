{ pkgs }:

{
  packages = [
    pkgs.gsd
  ];

  shellHook = ''
    echo "GSD 2: $(gsd --version 2>/dev/null || echo "not found")"
    echo "GSD state & CLI: fully isolated in ./ .gsd/ (project root)"
    echo "Run: gsd          # interactive mode"
    echo "     gsd auto      # autonomous mode"
  '';
}

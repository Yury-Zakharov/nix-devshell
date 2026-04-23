{ pkgs }:

{
  packages = [
    pkgs.bmad-method
  ];

  shellHook = ''
    echo "BMAD-METHOD: $(bmad-method --version 2>/dev/null || echo "not found")"
    echo "BMAD state & CLI: fully isolated in ./.bmad/ (project root)"
    echo ""
    echo "Common commands:"
    echo "  bmad-method install          # interactive setup"
    echo "  bmad-method install --yes    # non-interactive"
    echo "  bmad-help                    # ask what to do next"
  '';
}

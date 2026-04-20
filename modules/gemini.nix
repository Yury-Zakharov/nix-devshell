{ pkgs }:

{
  packages = [
    pkgs.gemini-cli
  ];

  env = {
    # Gemini does not fully respect GEMINI_CONFIG_DIR yet (known limitation)
    # We set XDG paths and document the remaining global tendency
  };

  shellHook = ''
    echo "Gemini: $(gemini --version 2>/dev/null || true)"
    echo "Gemini config: mostly in ~/.gemini (tool limitation). Consider monitoring ~/.gemini"
  '';
}

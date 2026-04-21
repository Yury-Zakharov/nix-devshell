{ pkgs }:

{
  packages = [
    pkgs.gemini-cli
  ];

  env = {
    # Gemini CLI respects XDG_CONFIG_HOME when set (base.nix forces it to project root)
  };

  shellHook = ''
    echo "Gemini: $(gemini --version 2>/dev/null || true)"
    echo "Gemini config: fully redirected to \$XDG_CONFIG_HOME/.gemini (project root)"
  '';
}

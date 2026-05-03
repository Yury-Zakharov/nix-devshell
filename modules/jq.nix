{ pkgs }:

{
  packages = [
    pkgs.jq
  ];

  env = {

  };

  shellHook = ''
    echo "jq: $(jq --version 2>/dev/null || true)"
  '';
}

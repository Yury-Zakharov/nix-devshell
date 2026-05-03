{ pkgs }:

{
  packages = [
    pkgs.jq
  ];

  shellHook = ''
    echo "jq: $(jq --version 2>/dev/null || true)"
  '';
}

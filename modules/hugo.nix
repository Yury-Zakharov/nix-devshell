{ pkgs }:

{
  packages = [
    pkgs.hugo
  ];

  shellHook = ''
    echo "Hugo: $(hugo version 2>/dev/null || true)"
  '';
}

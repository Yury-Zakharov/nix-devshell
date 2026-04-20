{ pkgs }:

{
  packages = [
    pkgs.get-shit-done
  ];

  env = { };

  shellHook = ''
    echo "Get-shit-done (gsd): fully contained in \$XDG_CACHE_HOME/get-shit-done"
  '';
}

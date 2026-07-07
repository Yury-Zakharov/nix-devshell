{ pkgs }:

{
  packages = [
    pkgs.nodejs
    pkgs.nodePackages.typescript
  ];

  shellHook = ''
    echo "TypeScript toolchain ready"
    echo "   node: $(node --version 2>/dev/null || true)"
    echo "   tsc:  $(tsc --version 2>/dev/null || true)"
  '';
}

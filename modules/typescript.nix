{ pkgs }:

{
  packages = [
    pkgs.nodejs
    pkgs.typescript
    pkgs.typescript-language-server
  ];

  shellHook = ''
    echo "TypeScript toolchain ready"
    echo "   node: $(node --version 2>/dev/null || true)"
    echo "   tsc:  $(tsc --version 2>/dev/null || true)"
  '';
}

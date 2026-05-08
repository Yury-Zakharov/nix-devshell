{ pkgs }:

let
  # Wrapped stack for perfect Stack experience inside Nix devShell
  # --nix --no-nix-pure ensures it uses the shell's env + libs without recursion
  stack-wrapped = pkgs.writeShellScriptBin "stack" ''
    exec ${pkgs.stack}/bin/stack --nix --no-nix-pure "$@"
  '';
in

{
  packages = [
    stack-wrapped
    pkgs.haskell-language-server
    pkgs.fourmolu

    # Common C libraries required by most Haskell packages via Stack
    pkgs.pkg-config
    pkgs.zlib
    pkgs.openssl
    pkgs.gmp
    pkgs.libffi
    pkgs.ncurses
  ];

  env = {
    # Total isolation - everything stays inside project root
    STACK_ROOT = "$PWD/.stack";
  };

  shellHook = ''
    # Explicit setup - zero implicit behavior
    mkdir -p "$STACK_ROOT" "$PWD/.stack/bin"

    # Make locally installed Stack binaries available in PATH
    export PATH="$PWD/.stack/bin:$PATH"

    echo "✅ Haskell + Stack environment ready (fully isolated)"
    echo "   STACK_ROOT → $STACK_ROOT"
    echo "   Tools:      stack (Nix-wrapped), haskell-language-server, fourmolu"
    echo "   Use stack build/test/exec/fmt exactly as before"
  '';
}

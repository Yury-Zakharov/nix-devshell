{ pkgs }:

{
  # Toolchain tracks nixos-unstable (same pin as gopls / golangci-lint).
  # Update path: nix flake update  (no separate updater; this is pkgs.go, not a vendored tarball).
  # GOTOOLCHAIN=local below stops `go` from downloading another toolchain into $HOME/sdk.
  packages = [
    pkgs.go
    pkgs.gopls
    pkgs.golangci-lint
    pkgs.delve
    pkgs.gotools
    pkgs.gcc
    pkgs.pkg-config
  ];

  env = {
    # GOPATH does not follow XDG. Default is $HOME/go — never use that.
    GOPATH     = "$PWD/.go";
    GOBIN      = "$PWD/.go/bin";
    GOMODCACHE = "$PWD/.go/pkg/mod";
    GOCACHE    = "$PWD/.cache/go-build";
    GOENV      = "$PWD/.config/go/env";

    # Process env wins over $GOROOT/go.env (which defaults to auto → $HOME/sdk).
    GOTOOLCHAIN = "local";
    GO111MODULE = "on";
    GOTELEMETRY = "off";

    GOPROXY = "https://proxy.golang.org,direct";
    GOSUMDB = "sum.golang.org";

    CGO_ENABLED = "1";
  };

  shellHook = ''
    mkdir -p "$GOBIN" "$GOMODCACHE" "$GOCACHE" "$(dirname "$GOENV")"

    # Project-local installs (`go install`) must win over nothing, not over nixpkgs.
    # Appended here so a later module's env.PATH cannot drop it.
    case ":$PATH:" in
      *":$GOBIN:"*) ;;
      *) export PATH="$GOBIN:$PATH" ;;
    esac

    if [ -f "$PWD/.gitignore" ] && ! grep -qxF '.go/' "$PWD/.gitignore"; then
      printf '\n# Go module cache, build outputs from go install, GOTOOLCHAIN state\n.go/\n' >> "$PWD/.gitignore"
      echo "✓ .go/ added to .gitignore"
    fi

    echo "✅ Go toolchain ready (isolated under project root)"
    echo "   go:         $(go version 2>/dev/null || echo missing)"
    echo "   GOPATH:     $GOPATH"
    echo "   GOMODCACHE: $GOMODCACHE"
    echo "   GOCACHE:    $GOCACHE"
    echo "   GOBIN:      $GOBIN"
    echo "   GOTOOLCHAIN=local (nixpkgs go only; nix flake update to bump)"
    echo "   Tools:      gopls, golangci-lint, dlv, gotools, gcc (cgo)"
    echo ""
    echo "New module:"
    echo "  go mod init example.com/$(basename "$PWD")"
    echo "Libraries:"
    echo "  go get example.com/mod@latest && go mod tidy"
    echo "Compile / run:"
    echo "  go build -o ./bin/app . && go run ."
    echo "Extra tool, project-local binary (not nixpkgs, not \$HOME):"
    echo "  go install golang.org/x/tools/gopls@latest   # lands in .go/bin"
  '';
}

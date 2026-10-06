{ pkgs }:

{
  # Toolchain tracks nixos-unstable (same pin as rust-analyzer / cargo-edit).
  # Update path: nix flake update  (no separate updater; this is pkgs.rustc, not rustup).
  # rustup is intentionally absent. rust-toolchain.toml is not honored.
  # A rustup install would write toolchains under RUSTUP_HOME below, never $HOME/.rustup.
  packages = [
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.clippy
    pkgs.rust-analyzer
    pkgs.cargo-edit # cargo add / rm / upgrade / set-version

    # -sys crates (openssl-sys, libz-sys, …). mkShell runs their setup hooks.
    pkgs.gcc
    pkgs.pkg-config
    pkgs.openssl
    pkgs.cmake
  ];

  env = {
    # Cargo does not follow XDG. Default CARGO_HOME is $HOME/.cargo — never use that.
    # Not $PWD/.cargo: that path is the project config dir (committable config.toml).
    # Registry, git db, credentials, and `cargo install` binaries live here instead.
    CARGO_HOME = "$PWD/.cargo-home";

    # Default is already ./target. Pin it so nothing redirects artifacts to $HOME.
    CARGO_TARGET_DIR = "$PWD/target";

    # Unused without rustup. Set so a later `cargo install rustup` cannot fall back to $HOME/.rustup.
    RUSTUP_HOME = "$PWD/.rustup";

    # rust-analyzer std sources. Store path, not a download.
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  shellHook = ''
    mkdir -p "$CARGO_HOME/bin" "$CARGO_TARGET_DIR" "$RUSTUP_HOME"

    # Project-local installs (`cargo install`) must win over nothing, not over nixpkgs.
    # Appended here so a later module's env.PATH cannot drop it.
    case ":$PATH:" in
      *":$CARGO_HOME/bin:"*) ;;
      *) export PATH="$CARGO_HOME/bin:$PATH" ;;
    esac

    if [ -f "$PWD/.gitignore" ]; then
      if ! grep -qxF '.cargo-home/' "$PWD/.gitignore"; then
        printf '\n# Cargo registry, git db, credentials, cargo install binaries\n.cargo-home/\n' >> "$PWD/.gitignore"
        echo "✓ .cargo-home/ added to .gitignore"
      fi
      if ! grep -qxF '.rustup/' "$PWD/.gitignore"; then
        printf '\n# rustup state, if a toolchain is ever installed (module does not install rustup)\n.rustup/\n' >> "$PWD/.gitignore"
        echo "✓ .rustup/ added to .gitignore"
      fi
      if ! grep -qxF 'target/' "$PWD/.gitignore"; then
        printf '\n# Cargo build artifacts (CARGO_TARGET_DIR)\ntarget/\n' >> "$PWD/.gitignore"
        echo "✓ target/ added to .gitignore"
      fi
    fi

    echo "✅ Rust toolchain ready (isolated under project root)"
    echo "   rustc:      $(rustc --version 2>/dev/null || echo missing)"
    echo "   cargo:      $(cargo --version 2>/dev/null || echo missing)"
    echo "   CARGO_HOME: $CARGO_HOME"
    echo "   target:     $CARGO_TARGET_DIR"
    echo "   RUSTUP_HOME:$RUSTUP_HOME (no rustup; nixpkgs pin only)"
    echo "   Bump:       nix flake update  (nixos-unstable rustc/cargo)"
    echo "   Tools:      rustfmt, clippy, rust-analyzer, cargo-edit, gcc, pkg-config, openssl, cmake"
    echo ""
    echo "New project:"
    echo "  cargo new .          # in an empty dir; or: cargo init"
    echo "Libraries:"
    echo "  cargo add serde --features derive && cargo fetch"
    echo "Compile / run:"
    echo "  cargo build && cargo run"
    echo "Extra tool, project-local binary (not nixpkgs, not \$HOME):"
    echo "  cargo install cargo-watch --locked   # lands in .cargo-home/bin"
  '';
}

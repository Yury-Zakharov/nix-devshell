# Single owner: this file owns base composition and explicit per-project extension.
# Zero implicit behaviour: overlays are applied once, early, and passed explicitly.

{ pkgs ? import <nixpkgs> {
    config.allowUnfree = true;
    overlays = import ./overlays.nix;
  }
, extraModules ? []
}:

let
  # Base modules — common to ALL projects (single declaration site)
  baseModulePaths = [
    ./modules/base.nix
  ];

  allModulePaths = baseModulePaths ++ extraModules;

  # CRITICAL: create a fresh pkgs with overlays for modules only
  # This forces the overlay to be evaluated before any module import
  modulePkgs = import <nixpkgs> {
    config.allowUnfree = true;
    overlays = import ./overlays.nix;
  };

  modules = map (path: import path { pkgs = modulePkgs; }) allModulePaths;

  merged = {
    packages = builtins.concatLists (map (m: m.packages or []) modules);
    env      = builtins.foldl' (acc: m: acc // (m.env or {})) {} modules;
    shellHook = builtins.concatStringsSep "\n" (map (m: m.shellHook or "") modules);
  };
in
pkgs.mkShell {
  packages = merged.packages;

  shellHook = ''
    # Explicit env injection from all modules — single owner: default.nix
    ${builtins.concatStringsSep "\n"
      (map (name: "export ${name}=\"${merged.env.${name}}\"")
           (builtins.attrNames merged.env))}

    ${merged.shellHook}
  '';
}

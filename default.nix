# Single owner: this file owns base composition and explicit per-project extension.
# Zero implicit behaviour: overlays are applied once, early, and passed explicitly.

{ pkgs
, extraModules ? []
}:

let
  # Base modules — common to ALL projects (single declaration site)
  baseModule = import ./modules/base.nix { inherit pkgs; };

  modules = [ baseModule ] ++ extraModules;

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

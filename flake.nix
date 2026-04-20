{
  description = "Reusable Nix devshell modules and templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
    in
    {
      templates.default = {
        path = ./templates/default;
        description = "Standard devshell (base + optional modules)";
      };

      # Single declaration site for all available modules
      modules = {
        base   = import ./modules/base.nix;
        dotnet = import ./modules/dotnet.nix;
        # Add every module you have here exactly once:
        # claude      = import ./modules/claude.nix;
        # elm         = import ./modules/elm.nix;
        # python      = import ./modules/python.nix;
        # ... (one line per module)
      };

      overlays = import ./overlays.nix;

      lib = {
        mkDevShell = { extraModules ? [] }: import ./default.nix {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = self.overlays;
          };
          inherit extraModules;
        };
      };
    };
}

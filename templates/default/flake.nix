{
  description = "Isolated development shell ([tool names here])";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:Yury-Zakharov/nix-devshell";
  };

  outputs = { self, nixpkgs, devshell }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = devshell.overlays;
      };

      # Choose modules for this project (single declaration site)
      extraModules = [
        devshell.modules.base
        devshell.modules.dotnet
        # devshell.modules.python
        # devshell.modules.elm
        # add/remove here only
      ];

      devShell = devshell.lib.mkDevShell { inherit pkgs extraModules; };
    in
    {
      devShells.${system}.default = devShell;
    };
}

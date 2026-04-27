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
        base         = import ./modules/base.nix;
        claude       = import ./modules/claude.nix;
        dotnet       = import ./modules/dotnet.nix;
        elm          = import ./modules/elm.nix;
        elm-land     = import ./modules/elm-land.nix;
        elm-spa      = import ./modules/elm-spa.nix;
        gemini       = import ./modules/gemini.nix;
        get-shit-done = import ./modules/get-shit-done.nix;
        gsd          = import ./modules/gsd.nix;
        hugo         = import ./modules/hugo.nix;
        kilocode-cli = import ./modules/kilocode-cli.nix;
        opencode     = import ./modules/opencode.nix;
        opencode-skills = import ./modules/opencode-skills.nix;
        opencode-commands = import ./modules/opencode-commands.nix;
        python       = import ./modules/python.nix;
        qwen-code    = import ./modules/qwen-code.nix;
        rendercv     = import ./modules/rendercv.nix;
        spec-kit     = import ./modules/spec-kit.nix;
        swarmvault   = import ./modules/swarmvault.nix;
        bmad-method  = import ./modules/bmad-method.nix;
        gitnexus     = import ./modules/gitnexus.nix;
        gitnexus-mcp = import ./modules/gitnexus-mcp.nix;
      };

      overlays = import ./overlays.nix;

      lib = {
        # Evaluate each module function with pkgs before passing to default.nix
        mkDevShell = { pkgs, extraModules ? [] }:
          let
            evaluatedModules = map (m: m { inherit pkgs; }) extraModules;
          in
          import ./default.nix {
            inherit pkgs;
            extraModules = evaluatedModules;
          };
      };
    };
}
